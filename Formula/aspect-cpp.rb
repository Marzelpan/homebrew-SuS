class AspectCpp < Formula
  desc "AspectC++ compiler"
  homepage "https://www.aspectc.org/"
  head "http://aspectc.org:8080/job/Daily/lastSuccessfulBuild/artifact/aspectcpp-source-daily.tar.gz"
  depends_on "llvm@6"

  def install
    ENV["TARGET"] = "macosx_x86_64-release"
    system "make", "-C", "Puma", "MINI=1"
    system "make", "-C", "AspectC++", "SHARED=1", "LLVMCONF=#{Formula["llvm@6"].opt_bin}/llvm-config"
    system "make", "-C", "Ag++"
    bin.install Dir["AspectC++/bin/#{ENV["TARGET"]}/*"]
  end

  test do
    # TODO
    system "false"
  end
end
