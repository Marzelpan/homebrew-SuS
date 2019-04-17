class KconfigFrontends < Formula
  desc "Packaging of the Linux kconfig parser and frontends"
  homepage "http://ymorin.is-a-geek.org/projects/kconfig-frontends"
  url "http://ymorin.is-a-geek.org/download/kconfig-frontends/kconfig-frontends-4.11.0.1.tar.xz"
  sha256 "2386c1775caf2820e70cb4fc1617229a05bf9cc02639ab93f84a9d39786339f6"

  depends_on "ncurses"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/kconfig", "-h"
  end
end
