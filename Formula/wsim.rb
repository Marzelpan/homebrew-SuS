# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
class Wsim < Formula
  desc "Embedded system full platform emulator"
  homepage "http://wsim.gforge.inria.fr/"
  head "https://ess.cs.uos.de/git/software/wsim.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "qt"
  depends_on "srecord"

  def install
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["qt5"].opt_lib/"pkgconfig"
    ENV.cxx11

    system "./bootstrap"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-platform-ez430chronos"
    system "make", "install"

    cd "utils/wsnet1" do
      system "./bootstrap"
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/wsim-ez430chronos", "--version"
  end
end
