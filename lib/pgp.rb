require 'iostreams'

class BaseRunner
    def self.execute(c)
        puts "Starting runner #{c.class.to_s}"
        c.run
        puts "End of runner #{c.class.to_s}"
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

        IOStreams::Pgp::Writer.open(
          @dest,
          recipient:         id[:email],
          signer:            id[:email],
          signer_passphrase: @passphrase
        ) do |output|
          output.puts(data)
        end

        File.delete @src
    end

    private

    def get_id
        IOStreams::Pgp.list_keys(key_id: @id).first
    end
end
