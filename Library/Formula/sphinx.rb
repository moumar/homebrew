require 'formula'

class Sphinx < Formula
  url 'http://sphinxsearch.com/downloads/sphinx-0.9.9.tar.gz'
  homepage 'http://www.sphinxsearch.com'
  md5 '7b9b618cb9b378f949bb1b91ddcc4f54'
  head 'http://sphinxsearch.googlecode.com/svn/trunk/'

  fails_with_llvm "fails with: ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"

  if ARGV.include? '--with-libstemmer'
    depends_on "libstemmer" => :build
  end

  def install
    args = ["--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"]
    # configure script won't auto-select PostgreSQL
    args << "--with-pgsql" if `/usr/bin/which pg_config`.size > 0
    args << "--without-mysql" if `/usr/bin/which mysql`.size <= 0

    system "./configure", *args

    if ARGV.include? '--with-libstemmer'
      inreplace "config/config.h", /^#define USE_LIBSTEMMER 0$/, "#define USE_LIBSTEMMER 1"
      inreplace "src/Makefile" do |s|
        libs = s.get_make_var("LIBS")
        libs << " " + HOMEBREW_PREFIX + "/lib/libstemmer.o"
        s.change_make_var! "LIBS", libs
      end
    end

    system "make install"
  end

  def options
    [
      ['--with-libstemmer', "Compile with libstemmer"]
    ]
  end

  def caveats
    <<-EOS.undent
    Sphinx depends on either MySQL or PostreSQL as a datasource.

    You can install these with Homebrew with:
      brew install mysql
        For MySQL server.

      brew install mysql-connector-c
        For MySQL client libraries only.

      brew install postgresql
        For PostgreSQL server.

    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
