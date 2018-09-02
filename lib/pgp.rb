require 'iostreams'

module InotiPGP

    class <<self
        attr_accessor :logger
    end

    class BaseRunner
        def self.execute(c)
            InotiPGP.logger.debug "Starting runner #{c.class.to_s}"
            c.run
            InotiPGP.logger.debug "End of runner #{c.class.to_s}"
        end
    end

    class Pgp

        attr_accessor :src, :dest, :id

        def initialize(src, dest, id, passphrase, gpg_exe='gpg')
            @src = src
            @dest = dest
            @id = id
            @passphrase = passphrase

            IOStreams::Pgp.executable = gpg_exe
        end

        def run
            id = get_id
            data = File.read @src

            # TODO handle error
            IOStreams::Pgp::Writer.open(
              @dest,
              recipient:         id[:email],
              signer:            id[:email],
              signer_passphrase: @passphrase
            ) do |output|
              output.puts(data)
            end
            InotiPGP.logger.info "File signed/encrypted for #{id[:email]}"

            File.delete @src
            InotiPGP.logger.debug "File deleted #{@src}"
        end

        private

        def get_id
            IOStreams::Pgp.list_keys(key_id: @id).first
        end
    end
end
