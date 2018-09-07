require_relative '../lib/pgp'

describe InotiPGP::Pgp do

  before do
    @pgp = InotiPGP::Pgp.new("/temp/src",
            "/temp/dest",
            "IAIDAIDAID",
            "thisismypassphrase"
            )
  end

  describe ".initialize" do
    it "check attribute access" do
      expect(@pgp.src).to eql("/temp/src")
      expect(@pgp.dest).to eql("/temp/dest")
      expect(@pgp.id).to eql("IAIDAIDAID")
    end
  end

end
