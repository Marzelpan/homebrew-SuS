class AspectCpp < Formula
  desc "AspectC++ compiler"
  homepage "https://www.aspectc.org/"
  head "http://aspectc.org:8080/job/Daily/lastSuccessfulBuild/artifact/aspectcpp-source-daily.tar.gz"
  depends_on "llvm@6"

  patch :p0, :DATA

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

__END__
Index: Puma/src/common/Config.cc
===================================================================
--- Puma/src/common/Config.cc (revision 840)
+++ Puma/src/common/Config.cc (working copy)
@@ -108,6 +108,8 @@
    {Config::SET_OPTION_ARG, NULL, "ptrdiff-type", "Set type for ptrdiff_t", OptsParser::AT_MANDATORY},
    {Config::SET_OPTION_ARG, NULL, "target", "Set target triple, which determines sizes and alignments for built-in types", OptsParser::AT_MANDATORY},
    {Config::SET_OPTION_ARG, NULL, "isystem", "Add a system include directory", OptsParser::AT_MANDATORY},
+   {Config::SET_OPTION_ARG, NULL, "isysroot", "Add a sysroot directory", OptsParser::AT_MANDATORY},
+   {Config::SET_OPTION_ARG, "F", NULL, "Add a framework include directory", OptsParser::AT_MANDATORY}, // macOS
    {0, 0, 0, 0, OptsParser::AT_NONE}
 };
 
Index: Ag++/AGxxConfig.cc
===================================================================
--- Ag++/AGxxConfig.cc  (revision 68)
+++ Ag++/AGxxConfig.cc  (working copy)
@@ -42,7 +42,8 @@
     "-print-file-name=", "-idirafter", "-imacros", "-iprefix", "-iwithprefix",
     "-iwithprefixbefore", "-isystem", "--gen_size_type", "-B", "-l", "-I", "-L",
     "-specs=", "-MF", "-MT", "-MQ", "-x", "--param=", "--param", "-Xlinker",
-    "-u", "-V", "-b", "-G", };
+    "-u", "-V", "-b", "-G", "-isysroot",
+    "-F", "-arch", }; // macOS
 
 string AGxxConfig::_gcc_option_info[] = { "-print","-dump", };
 
@@ -128,6 +129,10 @@
       "\t" "Override the compiler's target triple", OptsParser::AT_MANDATORY},
    { AGxxConfig::ACOPT_PRE_INCLUDE, "I", NULL,
       "\t\t" "Add new include path", OptsParser::AT_MANDATORY},
+   { AGxxConfig::ACOPT_PRE_ISYSROOT, "isysroot", NULL,
+      "\t\t" "Specify isysroot path", OptsParser::AT_MANDATORY},
+   { AGxxConfig::ACOPT_PRE_FRAMEWORK, "F", NULL,
+      "\t\t" "Add new framework include path", OptsParser::AT_MANDATORY}, // macOS
    { AGxxConfig::ACOPT_PRE_DEFINE, "D", NULL,
       "\t\t" "Define a preprocessor macro", OptsParser::AT_MANDATORY},
    { AGxxConfig::ACOPT_PRE_UNDEFINE, "U", NULL,
@@ -357,6 +362,18 @@
             (OptionItem::OPT_ACC | OptionItem::OPT_GCC));
         continue;
 
+      case ACOPT_PRE_ISYSROOT:
+        _optvec.pushback("--isysroot", " \"" + op.getArgument() + "\" ",
+            (OptionItem::OPT_ACC));
+        _optvec.pushback("-isysroot", " \"" + op.getArgument() + "\" ",
+            (OptionItem::OPT_GCC));
+        continue;
+
+      case ACOPT_PRE_FRAMEWORK:
+        _optvec.pushback("-F", " \"" + op.getArgument() + "\" ",
+            (OptionItem::OPT_ACC | OptionItem::OPT_GCC));
+        continue;
+
       case ACOPT_SYS_INCLUDE:
         _optvec.pushback("--isystem", " \"" + op.getArgument() + "\" ",
             (OptionItem::OPT_ACC ));
Index: Ag++/AGxxConfig.h
===================================================================
--- Ag++/AGxxConfig.h (revision 68)
+++ Ag++/AGxxConfig.h (working copy)
@@ -186,6 +186,8 @@
     ACOPT_PRE_INCLUDE,
     ACOPT_PRE_DEFINE,
     ACOPT_PRE_UNDEFINE,
+    ACOPT_PRE_ISYSROOT,
+    ACOPT_PRE_FRAMEWORK, // macOS
     ACOPT_ALWAYS_INCLUDE,
     ACOPT_SYS_INCLUDE
   };
Index: AspectC++/ACProject.cc
===================================================================
--- AspectC++/ACProject.cc  (revision 1598)
+++ AspectC++/ACProject.cc  (working copy)
@@ -300,9 +300,9 @@
       Args.push_back("-fheinous-gnu-extensions"); // see bug 766 (ignore strange casts of LValues)
     }
 
-    // Pass macro definitions and include paths to clang. Everything else is
+    // Pass macro definitions, include paths, and framework paths to clang. Everything else is
     // Puma-specific and dropped.
-    if ((strncmp(Name, "-I", 2) && strncmp(Name, "-i", 2)))
+    if (strncmp(Name, "-I", 2) && strncmp(Name, "-i", 2) && strncmp(Name, "-F", 2))
       continue;
 
     Args.push_back(Name);
