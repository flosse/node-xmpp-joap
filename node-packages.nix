{ self, fetchurl, fetchgit ? null, lib }:

{
  by-spec."assertion-error"."1.0.0" =
    self.by-version."assertion-error"."1.0.0";
  by-version."assertion-error"."1.0.0" = self.buildNodePackage {
    name = "assertion-error-1.0.0";
    version = "1.0.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/assertion-error/-/assertion-error-1.0.0.tgz";
      name = "assertion-error-1.0.0.tgz";
      sha1 = "c7f85438fdd466bc7ca16ab90c81513797a5d23b";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."async"."~0.9.0" =
    self.by-version."async"."0.9.0";
  by-version."async"."0.9.0" = self.buildNodePackage {
    name = "async-0.9.0";
    version = "0.9.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/async/-/async-0.9.0.tgz";
      name = "async-0.9.0.tgz";
      sha1 = "ac3613b1da9bed1b47510bb4651b8931e47146c7";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "async" = self.by-version."async"."0.9.0";
  by-spec."backoff"."~2.3.0" =
    self.by-version."backoff"."2.3.0";
  by-version."backoff"."2.3.0" = self.buildNodePackage {
    name = "backoff-2.3.0";
    version = "2.3.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/backoff/-/backoff-2.3.0.tgz";
      name = "backoff-2.3.0.tgz";
      sha1 = "ee7c7e38093f92e472859db635e7652454fc21ea";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."bindings"."^1.2.1" =
    self.by-version."bindings"."1.2.1";
  by-version."bindings"."1.2.1" = self.buildNodePackage {
    name = "bindings-1.2.1";
    version = "1.2.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/bindings/-/bindings-1.2.1.tgz";
      name = "bindings-1.2.1.tgz";
      sha1 = "14ad6113812d2d37d72e67b4cacb4bb726505f11";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."bindings"."~1.1.1" =
    self.by-version."bindings"."1.1.1";
  by-version."bindings"."1.1.1" = self.buildNodePackage {
    name = "bindings-1.1.1";
    version = "1.1.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/bindings/-/bindings-1.1.1.tgz";
      name = "bindings-1.1.1.tgz";
      sha1 = "951f7ae010302ffc50b265b124032017ed2bf6f3";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."bindings"."~1.2.1" =
    self.by-version."bindings"."1.2.1";
  by-spec."chai".">=1.9.2 <3" =
    self.by-version."chai"."2.3.0";
  by-version."chai"."2.3.0" = self.buildNodePackage {
    name = "chai-2.3.0";
    version = "2.3.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/chai/-/chai-2.3.0.tgz";
      name = "chai-2.3.0.tgz";
      sha1 = "8a2f6a34748da801090fd73287b2aa739a4e909a";
    };
    deps = {
      "assertion-error-1.0.0" = self.by-version."assertion-error"."1.0.0";
      "deep-eql-0.1.3" = self.by-version."deep-eql"."0.1.3";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."chai"."~2.3.0" =
    self.by-version."chai"."2.3.0";
  "chai" = self.by-version."chai"."2.3.0";
  by-spec."coffee-script"."~1.9.2" =
    self.by-version."coffee-script"."1.9.2";
  by-version."coffee-script"."1.9.2" = self.buildNodePackage {
    name = "coffee-script-1.9.2";
    version = "1.9.2";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/coffee-script/-/coffee-script-1.9.2.tgz";
      name = "coffee-script-1.9.2.tgz";
      sha1 = "2da4b663c61c6d1d851788aa31f941fc7b63edf3";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "coffee-script" = self.by-version."coffee-script"."1.9.2";
  by-spec."commander"."0.6.1" =
    self.by-version."commander"."0.6.1";
  by-version."commander"."0.6.1" = self.buildNodePackage {
    name = "commander-0.6.1";
    version = "0.6.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/commander/-/commander-0.6.1.tgz";
      name = "commander-0.6.1.tgz";
      sha1 = "fa68a14f6a945d54dbbe50d8cdb3320e9e3b1a06";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."commander"."2.3.0" =
    self.by-version."commander"."2.3.0";
  by-version."commander"."2.3.0" = self.buildNodePackage {
    name = "commander-2.3.0";
    version = "2.3.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/commander/-/commander-2.3.0.tgz";
      name = "commander-2.3.0.tgz";
      sha1 = "fd430e889832ec353b9acd1de217c11cb3eef873";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."debug"."2.0.0" =
    self.by-version."debug"."2.0.0";
  by-version."debug"."2.0.0" = self.buildNodePackage {
    name = "debug-2.0.0";
    version = "2.0.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/debug/-/debug-2.0.0.tgz";
      name = "debug-2.0.0.tgz";
      sha1 = "89bd9df6732b51256bc6705342bba02ed12131ef";
    };
    deps = {
      "ms-0.6.2" = self.by-version."ms"."0.6.2";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."debug"."^0.8.1" =
    self.by-version."debug"."0.8.1";
  by-version."debug"."0.8.1" = self.buildNodePackage {
    name = "debug-0.8.1";
    version = "0.8.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/debug/-/debug-0.8.1.tgz";
      name = "debug-0.8.1.tgz";
      sha1 = "20ff4d26f5e422cb68a1bacbbb61039ad8c1c130";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."debug"."~2.0.0" =
    self.by-version."debug"."2.0.0";
  by-spec."debug"."~2.2.0" =
    self.by-version."debug"."2.2.0";
  by-version."debug"."2.2.0" = self.buildNodePackage {
    name = "debug-2.2.0";
    version = "2.2.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/debug/-/debug-2.2.0.tgz";
      name = "debug-2.2.0.tgz";
      sha1 = "f87057e995b1a1f6ae6a4960664137bc56f039da";
    };
    deps = {
      "ms-0.7.1" = self.by-version."ms"."0.7.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."deep-eql"."0.1.3" =
    self.by-version."deep-eql"."0.1.3";
  by-version."deep-eql"."0.1.3" = self.buildNodePackage {
    name = "deep-eql-0.1.3";
    version = "0.1.3";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/deep-eql/-/deep-eql-0.1.3.tgz";
      name = "deep-eql-0.1.3.tgz";
      sha1 = "ef558acab8de25206cd713906d74e56930eb69f2";
    };
    deps = {
      "type-detect-0.1.1" = self.by-version."type-detect"."0.1.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."diff"."1.4.0" =
    self.by-version."diff"."1.4.0";
  by-version."diff"."1.4.0" = self.buildNodePackage {
    name = "diff-1.4.0";
    version = "1.4.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/diff/-/diff-1.4.0.tgz";
      name = "diff-1.4.0.tgz";
      sha1 = "7f28d2eb9ee7b15a97efd89ce63dcfdaa3ccbabf";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."escape-string-regexp"."1.0.2" =
    self.by-version."escape-string-regexp"."1.0.2";
  by-version."escape-string-regexp"."1.0.2" = self.buildNodePackage {
    name = "escape-string-regexp-1.0.2";
    version = "1.0.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/escape-string-regexp/-/escape-string-regexp-1.0.2.tgz";
      name = "escape-string-regexp-1.0.2.tgz";
      sha1 = "4dbc2fe674e71949caf3fb2695ce7f2dc1d9a8d1";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."formatio"."1.1.1" =
    self.by-version."formatio"."1.1.1";
  by-version."formatio"."1.1.1" = self.buildNodePackage {
    name = "formatio-1.1.1";
    version = "1.1.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/formatio/-/formatio-1.1.1.tgz";
      name = "formatio-1.1.1.tgz";
      sha1 = "5ed3ccd636551097383465d996199100e86161e9";
    };
    deps = {
      "samsam-1.1.2" = self.by-version."samsam"."1.1.2";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."glob"."3.2.3" =
    self.by-version."glob"."3.2.3";
  by-version."glob"."3.2.3" = self.buildNodePackage {
    name = "glob-3.2.3";
    version = "3.2.3";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/glob/-/glob-3.2.3.tgz";
      name = "glob-3.2.3.tgz";
      sha1 = "e313eeb249c7affaa5c475286b0e115b59839467";
    };
    deps = {
      "minimatch-0.2.14" = self.by-version."minimatch"."0.2.14";
      "graceful-fs-2.0.3" = self.by-version."graceful-fs"."2.0.3";
      "inherits-2.0.1" = self.by-version."inherits"."2.0.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."graceful-fs"."~2.0.0" =
    self.by-version."graceful-fs"."2.0.3";
  by-version."graceful-fs"."2.0.3" = self.buildNodePackage {
    name = "graceful-fs-2.0.3";
    version = "2.0.3";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/graceful-fs/-/graceful-fs-2.0.3.tgz";
      name = "graceful-fs-2.0.3.tgz";
      sha1 = "7cd2cdb228a4a3f36e95efa6cc142de7d1a136d0";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."growl"."1.8.1" =
    self.by-version."growl"."1.8.1";
  by-version."growl"."1.8.1" = self.buildNodePackage {
    name = "growl-1.8.1";
    version = "1.8.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/growl/-/growl-1.8.1.tgz";
      name = "growl-1.8.1.tgz";
      sha1 = "4b2dec8d907e93db336624dcec0183502f8c9428";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."iconv"."~2.1.5" =
    self.by-version."iconv"."2.1.7";
  by-version."iconv"."2.1.7" = self.buildNodePackage {
    name = "iconv-2.1.7";
    version = "2.1.7";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/iconv/-/iconv-2.1.7.tgz";
      name = "iconv-2.1.7.tgz";
      sha1 = "6909c474c2f538be0a1eee19a8f0f88047220822";
    };
    deps = {
      "nan-1.8.4" = self.by-version."nan"."1.8.4";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."inherits"."2" =
    self.by-version."inherits"."2.0.1";
  by-version."inherits"."2.0.1" = self.buildNodePackage {
    name = "inherits-2.0.1";
    version = "2.0.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/inherits/-/inherits-2.0.1.tgz";
      name = "inherits-2.0.1.tgz";
      sha1 = "b17d08d326b4423e568eff719f91b0b1cbdf69f1";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."inherits"."2.0.1" =
    self.by-version."inherits"."2.0.1";
  by-spec."jade"."0.26.3" =
    self.by-version."jade"."0.26.3";
  by-version."jade"."0.26.3" = self.buildNodePackage {
    name = "jade-0.26.3";
    version = "0.26.3";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/jade/-/jade-0.26.3.tgz";
      name = "jade-0.26.3.tgz";
      sha1 = "8f10d7977d8d79f2f6ff862a81b0513ccb25686c";
    };
    deps = {
      "commander-0.6.1" = self.by-version."commander"."0.6.1";
      "mkdirp-0.3.0" = self.by-version."mkdirp"."0.3.0";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."lolex"."1.1.0" =
    self.by-version."lolex"."1.1.0";
  by-version."lolex"."1.1.0" = self.buildNodePackage {
    name = "lolex-1.1.0";
    version = "1.1.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/lolex/-/lolex-1.1.0.tgz";
      name = "lolex-1.1.0.tgz";
      sha1 = "5dbbbc850395e7523c74b3586f7fbd2626d25b1b";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."lru-cache"."2" =
    self.by-version."lru-cache"."2.6.3";
  by-version."lru-cache"."2.6.3" = self.buildNodePackage {
    name = "lru-cache-2.6.3";
    version = "2.6.3";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/lru-cache/-/lru-cache-2.6.3.tgz";
      name = "lru-cache-2.6.3.tgz";
      sha1 = "51ccd0b4fc0c843587d7a5709ce4d3b7629bedc5";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."ltx"."^0.5.2" =
    self.by-version."ltx"."0.5.2";
  by-version."ltx"."0.5.2" = self.buildNodePackage {
    name = "ltx-0.5.2";
    version = "0.5.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/ltx/-/ltx-0.5.2.tgz";
      name = "ltx-0.5.2.tgz";
      sha1 = "3a049fc30ab8982c227803a74b26c02fe225cef8";
    };
    deps = {
      "sax-0.6.1" = self.by-version."sax"."0.6.1";
      "node-expat-2.3.8" = self.by-version."node-expat"."2.3.8";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."ltx"."~0.9.0" =
    self.by-version."ltx"."0.9.0";
  by-version."ltx"."0.9.0" = self.buildNodePackage {
    name = "ltx-0.9.0";
    version = "0.9.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/ltx/-/ltx-0.9.0.tgz";
      name = "ltx-0.9.0.tgz";
      sha1 = "09055d4791b074d58c7d81d7ef0d91a71ef3c8a3";
    };
    deps = {
      "sax-0.6.1" = self.by-version."sax"."0.6.1";
      "node-expat-2.3.8" = self.by-version."node-expat"."2.3.8";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "ltx" = self.by-version."ltx"."0.9.0";
  by-spec."minimatch"."~0.2.11" =
    self.by-version."minimatch"."0.2.14";
  by-version."minimatch"."0.2.14" = self.buildNodePackage {
    name = "minimatch-0.2.14";
    version = "0.2.14";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/minimatch/-/minimatch-0.2.14.tgz";
      name = "minimatch-0.2.14.tgz";
      sha1 = "c74e780574f63c6f9a090e90efbe6ef53a6a756a";
    };
    deps = {
      "lru-cache-2.6.3" = self.by-version."lru-cache"."2.6.3";
      "sigmund-1.0.0" = self.by-version."sigmund"."1.0.0";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."minimist"."0.0.8" =
    self.by-version."minimist"."0.0.8";
  by-version."minimist"."0.0.8" = self.buildNodePackage {
    name = "minimist-0.0.8";
    version = "0.0.8";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/minimist/-/minimist-0.0.8.tgz";
      name = "minimist-0.0.8.tgz";
      sha1 = "857fcabfc3397d2625b8228262e86aa7a011b05d";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."mkdirp"."0.3.0" =
    self.by-version."mkdirp"."0.3.0";
  by-version."mkdirp"."0.3.0" = self.buildNodePackage {
    name = "mkdirp-0.3.0";
    version = "0.3.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/mkdirp/-/mkdirp-0.3.0.tgz";
      name = "mkdirp-0.3.0.tgz";
      sha1 = "1bbf5ab1ba827af23575143490426455f481fe1e";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."mkdirp"."0.5.0" =
    self.by-version."mkdirp"."0.5.0";
  by-version."mkdirp"."0.5.0" = self.buildNodePackage {
    name = "mkdirp-0.5.0";
    version = "0.5.0";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/mkdirp/-/mkdirp-0.5.0.tgz";
      name = "mkdirp-0.5.0.tgz";
      sha1 = "1d73076a6df986cd9344e15e71fcc05a4c9abf12";
    };
    deps = {
      "minimist-0.0.8" = self.by-version."minimist"."0.0.8";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."mocha"."~2.2.5" =
    self.by-version."mocha"."2.2.5";
  by-version."mocha"."2.2.5" = self.buildNodePackage {
    name = "mocha-2.2.5";
    version = "2.2.5";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/mocha/-/mocha-2.2.5.tgz";
      name = "mocha-2.2.5.tgz";
      sha1 = "d3b72a4fe49ec9439353f1ac893dbc430d993140";
    };
    deps = {
      "commander-2.3.0" = self.by-version."commander"."2.3.0";
      "debug-2.0.0" = self.by-version."debug"."2.0.0";
      "diff-1.4.0" = self.by-version."diff"."1.4.0";
      "escape-string-regexp-1.0.2" = self.by-version."escape-string-regexp"."1.0.2";
      "glob-3.2.3" = self.by-version."glob"."3.2.3";
      "growl-1.8.1" = self.by-version."growl"."1.8.1";
      "jade-0.26.3" = self.by-version."jade"."0.26.3";
      "mkdirp-0.5.0" = self.by-version."mkdirp"."0.5.0";
      "supports-color-1.2.1" = self.by-version."supports-color"."1.2.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "mocha" = self.by-version."mocha"."2.2.5";
  by-spec."ms"."0.6.2" =
    self.by-version."ms"."0.6.2";
  by-version."ms"."0.6.2" = self.buildNodePackage {
    name = "ms-0.6.2";
    version = "0.6.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/ms/-/ms-0.6.2.tgz";
      name = "ms-0.6.2.tgz";
      sha1 = "d89c2124c6fdc1353d65a8b77bf1aac4b193708c";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."ms"."0.7.1" =
    self.by-version."ms"."0.7.1";
  by-version."ms"."0.7.1" = self.buildNodePackage {
    name = "ms-0.7.1";
    version = "0.7.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/ms/-/ms-0.7.1.tgz";
      name = "ms-0.7.1.tgz";
      sha1 = "9cd13c03adbff25b65effde7ce864ee952017098";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."nan"."^1.5.1" =
    self.by-version."nan"."1.8.4";
  by-version."nan"."1.8.4" = self.buildNodePackage {
    name = "nan-1.8.4";
    version = "1.8.4";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/nan/-/nan-1.8.4.tgz";
      name = "nan-1.8.4.tgz";
      sha1 = "3c76b5382eab33e44b758d2813ca9d92e9342f34";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."nan"."~1.2.0" =
    self.by-version."nan"."1.2.0";
  by-version."nan"."1.2.0" = self.buildNodePackage {
    name = "nan-1.2.0";
    version = "1.2.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/nan/-/nan-1.2.0.tgz";
      name = "nan-1.2.0.tgz";
      sha1 = "9c4d63ce9e4f8e95de2d574e18f7925554a8a8ef";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."nan"."~1.8.0" =
    self.by-version."nan"."1.8.4";
  by-spec."nan"."~1.8.4" =
    self.by-version."nan"."1.8.4";
  by-spec."node-expat"."~2.3.0" =
    self.by-version."node-expat"."2.3.8";
  by-version."node-expat"."2.3.8" = self.buildNodePackage {
    name = "node-expat-2.3.8";
    version = "2.3.8";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/node-expat/-/node-expat-2.3.8.tgz";
      name = "node-expat-2.3.8.tgz";
      sha1 = "d8244afae7ee8783be438eba7c167535bdd935c4";
    };
    deps = {
      "bindings-1.2.1" = self.by-version."bindings"."1.2.1";
      "debug-2.2.0" = self.by-version."debug"."2.2.0";
      "iconv-2.1.7" = self.by-version."iconv"."2.1.7";
      "nan-1.8.4" = self.by-version."nan"."1.8.4";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."node-expat"."~2.3.8" =
    self.by-version."node-expat"."2.3.8";
  "node-expat" = self.by-version."node-expat"."2.3.8";
  by-spec."node-stringprep"."^0.5.2" =
    self.by-version."node-stringprep"."0.5.4";
  by-version."node-stringprep"."0.5.4" = self.buildNodePackage {
    name = "node-stringprep-0.5.4";
    version = "0.5.4";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/node-stringprep/-/node-stringprep-0.5.4.tgz";
      name = "node-stringprep-0.5.4.tgz";
      sha1 = "dd03b3d8f6f83137754cc1ea1a55675447b0ab92";
    };
    deps = {
      "nan-1.2.0" = self.by-version."nan"."1.2.0";
      "bindings-1.1.1" = self.by-version."bindings"."1.1.1";
      "debug-2.0.0" = self.by-version."debug"."2.0.0";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."node-stringprep"."~0.7.0" =
    self.by-version."node-stringprep"."0.7.0";
  by-version."node-stringprep"."0.7.0" = self.buildNodePackage {
    name = "node-stringprep-0.7.0";
    version = "0.7.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/node-stringprep/-/node-stringprep-0.7.0.tgz";
      name = "node-stringprep-0.7.0.tgz";
      sha1 = "c8a8deac9217db97ef3eb20dfa817d7e716f56b5";
    };
    deps = {
      "bindings-1.2.1" = self.by-version."bindings"."1.2.1";
      "debug-2.0.0" = self.by-version."debug"."2.0.0";
      "nan-1.8.4" = self.by-version."nan"."1.8.4";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "node-stringprep" = self.by-version."node-stringprep"."0.7.0";
  by-spec."node-uuid"."~1.4.3" =
    self.by-version."node-uuid"."1.4.3";
  by-version."node-uuid"."1.4.3" = self.buildNodePackage {
    name = "node-uuid-1.4.3";
    version = "1.4.3";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/node-uuid/-/node-uuid-1.4.3.tgz";
      name = "node-uuid-1.4.3.tgz";
      sha1 = "319bb7a56e7cb63f00b5c0cd7851cd4b4ddf1df9";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "node-uuid" = self.by-version."node-uuid"."1.4.3";
  by-spec."node-xmpp-core"."~1.0.0-alpha14" =
    self.by-version."node-xmpp-core"."1.0.0-alpha9";
  by-version."node-xmpp-core"."1.0.0-alpha9" = self.buildNodePackage {
    name = "node-xmpp-core-1.0.0-alpha9";
    version = "1.0.0-alpha9";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/node-xmpp-core/-/node-xmpp-core-1.0.0-alpha9.tgz";
      name = "node-xmpp-core-1.0.0-alpha9.tgz";
      sha1 = "64b2b41e9f59fc910c71fe648c6be2bc4ecef7f1";
    };
    deps = {
      "node-stringprep-0.5.4" = self.by-version."node-stringprep"."0.5.4";
      "reconnect-core-0.0.1" = self.by-version."reconnect-core"."0.0.1";
      "tls-connect-0.2.2" = self.by-version."tls-connect"."0.2.2";
      "ltx-0.5.2" = self.by-version."ltx"."0.5.2";
      "debug-0.8.1" = self.by-version."debug"."0.8.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "node-xmpp-core" = self.by-version."node-xmpp-core"."1.0.0-alpha9";
  by-spec."reconnect-core"."https://github.com/dodo/reconnect-core/tarball/merged" =
    self.by-version."reconnect-core"."0.0.1";
  by-version."reconnect-core"."0.0.1" = self.buildNodePackage {
    name = "reconnect-core-0.0.1";
    version = "0.0.1";
    bin = false;
    src = fetchurl {
      url = "https://github.com/dodo/reconnect-core/tarball/merged";
      name = "reconnect-core-0.0.1.tgz";
      sha256 = "431dd7a1578061815270e4ad59c6e8b40dff6b308244973e1c11049ccbf1629b";
    };
    deps = {
      "backoff-2.3.0" = self.by-version."backoff"."2.3.0";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."samsam"."~1.1" =
    self.by-version."samsam"."1.1.2";
  by-version."samsam"."1.1.2" = self.buildNodePackage {
    name = "samsam-1.1.2";
    version = "1.1.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/samsam/-/samsam-1.1.2.tgz";
      name = "samsam-1.1.2.tgz";
      sha1 = "bec11fdc83a9fda063401210e40176c3024d1567";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."sax"."~0.6.0" =
    self.by-version."sax"."0.6.1";
  by-version."sax"."0.6.1" = self.buildNodePackage {
    name = "sax-0.6.1";
    version = "0.6.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/sax/-/sax-0.6.1.tgz";
      name = "sax-0.6.1.tgz";
      sha1 = "563b19c7c1de892e09bfc4f2fc30e3c27f0952b9";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."sigmund"."~1.0.0" =
    self.by-version."sigmund"."1.0.0";
  by-version."sigmund"."1.0.0" = self.buildNodePackage {
    name = "sigmund-1.0.0";
    version = "1.0.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/sigmund/-/sigmund-1.0.0.tgz";
      name = "sigmund-1.0.0.tgz";
      sha1 = "66a2b3a749ae8b5fb89efd4fcc01dc94fbe02296";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."sinon".">=1.4.0 <2" =
    self.by-version."sinon"."1.14.1";
  by-version."sinon"."1.14.1" = self.buildNodePackage {
    name = "sinon-1.14.1";
    version = "1.14.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/sinon/-/sinon-1.14.1.tgz";
      name = "sinon-1.14.1.tgz";
      sha1 = "d82797841918734507c94b7a73e3f560904578ad";
    };
    deps = {
      "formatio-1.1.1" = self.by-version."formatio"."1.1.1";
      "util-0.10.3" = self.by-version."util"."0.10.3";
      "lolex-1.1.0" = self.by-version."lolex"."1.1.0";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."sinon"."~1.14.1" =
    self.by-version."sinon"."1.14.1";
  "sinon" = self.by-version."sinon"."1.14.1";
  by-spec."sinon-chai"."~2.7.0" =
    self.by-version."sinon-chai"."2.7.0";
  by-version."sinon-chai"."2.7.0" = self.buildNodePackage {
    name = "sinon-chai-2.7.0";
    version = "2.7.0";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/sinon-chai/-/sinon-chai-2.7.0.tgz";
      name = "sinon-chai-2.7.0.tgz";
      sha1 = "493df3a3d758933fdd3678d011a4f738d5e72540";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [
      self.by-version."chai"."2.3.0"
      self.by-version."sinon"."1.14.1"];
    os = [ ];
    cpu = [ ];
  };
  "sinon-chai" = self.by-version."sinon-chai"."2.7.0";
  by-spec."supports-color"."~1.2.0" =
    self.by-version."supports-color"."1.2.1";
  by-version."supports-color"."1.2.1" = self.buildNodePackage {
    name = "supports-color-1.2.1";
    version = "1.2.1";
    bin = true;
    src = fetchurl {
      url = "http://registry.npmjs.org/supports-color/-/supports-color-1.2.1.tgz";
      name = "supports-color-1.2.1.tgz";
      sha1 = "12ee21507086cd98c1058d9ec0f4ac476b7af3b2";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."tls-connect"."^0.2.2" =
    self.by-version."tls-connect"."0.2.2";
  by-version."tls-connect"."0.2.2" = self.buildNodePackage {
    name = "tls-connect-0.2.2";
    version = "0.2.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/tls-connect/-/tls-connect-0.2.2.tgz";
      name = "tls-connect-0.2.2.tgz";
      sha1 = "1d88d4f4cb829a0741b6acd05d1df73e0d566fd0";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."toobusy-js"."^0.4.2" =
    self.by-version."toobusy-js"."0.4.2";
  by-version."toobusy-js"."0.4.2" = self.buildNodePackage {
    name = "toobusy-js-0.4.2";
    version = "0.4.2";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/toobusy-js/-/toobusy-js-0.4.2.tgz";
      name = "toobusy-js-0.4.2.tgz";
      sha1 = "551f2bba38ccfd3c3d2e37d10f59d5abd13e686d";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  "toobusy-js" = self.by-version."toobusy-js"."0.4.2";
  by-spec."type-detect"."0.1.1" =
    self.by-version."type-detect"."0.1.1";
  by-version."type-detect"."0.1.1" = self.buildNodePackage {
    name = "type-detect-0.1.1";
    version = "0.1.1";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/type-detect/-/type-detect-0.1.1.tgz";
      name = "type-detect-0.1.1.tgz";
      sha1 = "0ba5ec2a885640e470ea4e8505971900dac58822";
    };
    deps = {
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
  by-spec."util".">=0.10.3 <1" =
    self.by-version."util"."0.10.3";
  by-version."util"."0.10.3" = self.buildNodePackage {
    name = "util-0.10.3";
    version = "0.10.3";
    bin = false;
    src = fetchurl {
      url = "http://registry.npmjs.org/util/-/util-0.10.3.tgz";
      name = "util-0.10.3.tgz";
      sha1 = "7afb1afe50805246489e3db7fe0ed379336ac0f9";
    };
    deps = {
      "inherits-2.0.1" = self.by-version."inherits"."2.0.1";
    };
    optionalDependencies = {
    };
    peerDependencies = [];
    os = [ ];
    cpu = [ ];
  };
}
