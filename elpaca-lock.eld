((acp :source "elpaca-menu-lock-file" :recipe
   (:package "acp" :fetcher github :repo "xenodium/acp.el" :files
     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
       (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
     :source "elpaca-menu-lock-file" :id acp :type git :protocol https :inherit t :depth treeless :ref
     "3ddfa907eb7f17949a4a8e731ea5c5241e6cbcb4"))
  (agent-shell :source "elpaca-menu-lock-file" :recipe
    (:package "agent-shell" :fetcher github :repo "xenodium/agent-shell" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id agent-shell :type git :protocol https :inherit t :depth treeless :ref
      "aa54cbd0fd8cc32e002fa46d572af50cce074cc3"))
  (apheleia :source "elpaca-menu-lock-file" :recipe
    (:package "apheleia" :fetcher github :repo "radian-software/apheleia" :files
      (:defaults ("scripts" "scripts/formatters")) :source "elpaca-menu-lock-file" :id apheleia :type git :protocol
      https :inherit t :depth treeless :ref "70a638ff286549e1fbad45719ab6582159fa2c36"))
  (auth-source-1password :source "elpaca-menu-lock-file" :recipe
    (:package "auth-source-1password" :fetcher github :repo "dlobraico/auth-source-1password" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id auth-source-1password :type git :protocol https :inherit t :depth treeless
      :ref "10961bdc8a3ed551dde29fde416843058bea2374"))
  (batppuccin-mocha-theme :source "elpaca-menu-lock-file" :recipe
    (:source "elpaca-menu-lock-file" :package "batppuccin-mocha-theme" :id batppuccin-mocha-theme :repo
      "https://github.com/bbatsov/batppuccin-emacs" :type git :protocol https :inherit t :depth treeless :ref
      "16a6f902cd2d9e25019b4c17a7ee41025f99b93d"))
  (buffer-guardian :source "elpaca-menu-lock-file" :recipe
    (:package "buffer-guardian" :fetcher github :repo "jamescherti/buffer-guardian.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id buffer-guardian :type git :protocol https :inherit t :depth treeless :ref
      "5b241c8144fe37d8a3b251b6792442f0652bec52"))
  (bufferlo :source "elpaca-menu-lock-file" :recipe
    (:package "bufferlo" :repo ("https://github.com/florommel/bufferlo" . "bufferlo") :tar "1.2" :host gnu :files
      ("*" (:exclude ".git")) :source "GNU ELPA" :id bufferlo :type git :protocol https :inherit t :depth treeless :ref
      "e254ec0f1b3e41af658de1c4c80ec2fb78ab3cc4"))
  (casual :source "elpaca-menu-lock-file" :recipe
    (:package "casual" :fetcher github :repo "kickingvegas/casual" :old-names
      (casual-agenda casual-bookmarks casual-calc casual-dired casual-editkit casual-ibuffer casual-info casual-isearch
        cc-isearch-menu casual-lib casual-re-builder)
      :files (:defaults "docs/images") :source "elpaca-menu-lock-file" :id casual :type git :protocol https :inherit t
      :depth treeless :ref "72fc24345934888528e823195d90cf0a60b948c9"))
  (compat :source "elpaca-menu-lock-file" :recipe
    (:package "compat" :repo ("https://github.com/emacs-compat/compat" . "compat") :tar "31.0.0.1" :host gnu :files
      ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id compat :wait t :type git :protocol https :inherit t
      :depth treeless :ref "ad1806f7f677c4e295ed1e603ae6a6a5d9f9d399"))
  (cond-let
    :source "elpaca-menu-lock-file" :recipe
    (:package "cond-let" :fetcher github :repo "tarsius/cond-let" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id cond-let :host github :type git :protocol https :inherit t :depth treeless
      :ref "c05079b0a5dd74eda1f986e40600745144deafea"))
  (consult :source "elpaca-menu-lock-file" :recipe
    (:package "consult" :repo "minad/consult" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id consult :type git :protocol https :inherit t :depth treeless :ref
      "1702e854b55adbd51242a0f7de96a72a7e10349c"))
  (consult-eglot :source "elpaca-menu-lock-file" :recipe
    (:package "consult-eglot" :fetcher github :repo "mohkale/consult-eglot" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id consult-eglot :type git :protocol https :inherit t :depth treeless :ref
      "d8b444aac39edfc6473ffbd228df3e9119451b51"))
  (consult-eglot-embark :source "elpaca-menu-lock-file" :recipe
    (:package "consult-eglot-embark" :fetcher github :repo "mohkale/consult-eglot" :files
      ("extensions/consult-eglot-embark/consult-eglot-embark*.el") :source "elpaca-menu-lock-file" :id
      consult-eglot-embark :type git :protocol https :inherit t :depth treeless :ref
      "d8b444aac39edfc6473ffbd228df3e9119451b51"))
  (consult-project-extra :source "elpaca-menu-lock-file" :recipe
    (:package "consult-project-extra" :fetcher github :repo "Qkessler/consult-project-extra" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id consult-project-extra :type git :protocol https :inherit t :depth treeless
      :ref "52c453b7f85dea90cc53ff8fba750795606415df"))
  (copilot :source "elpaca-menu-lock-file" :recipe
    (:package "copilot" :fetcher github :repo "copilot-emacs/copilot.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id copilot :type git :protocol https :inherit t :depth treeless :ref
      "ab5c58bc969f52f6d75e972658f2c3381c70b4fa"))
  (corfu :source "elpaca-menu-lock-file" :recipe
    (:package "corfu" :repo "minad/corfu" :files (:defaults "extensions/corfu-*.el") :fetcher github :source
      "elpaca-menu-lock-file" :id corfu :type git :protocol https :inherit t :depth treeless :ref
      "4a9c67da16eb64cadaa4bfcc16713188145c83da"))
  (corfu-prescient :source "elpaca-menu-lock-file" :recipe
    (:package "corfu-prescient" :fetcher github :repo "radian-software/prescient.el" :files ("corfu-prescient.el")
      :source "elpaca-menu-lock-file" :id corfu-prescient :type git :protocol https :inherit t :depth treeless :ref
      "87e2d2f2ddf24f591a5f70cc90d2afb4537caa18"))
  (coterm :source "elpaca-menu-lock-file" :recipe
    (:package "coterm" :repo ("https://repo.or.cz/emacs-coterm.git" . "coterm") :tar "1.6" :host gnu :files
      ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id coterm :type git :protocol https :inherit t :depth
      treeless :ref "ce3206fbd7156685e2d2f3fbc39b3eea3334754b"))
  (csv-mode :source "elpaca-menu-lock-file" :recipe
    (:package "csv-mode" :repo ("https://github.com/emacsmirror/gnu_elpa" . "csv-mode") :tar "1.27" :host gnu :branch
      "externals/csv-mode" :files ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id csv-mode :type git
      :protocol https :inherit t :depth treeless :ref "3a441a41a3b1d61c2a9c9f5f091cb38ba6b45d47"))
  (dash :source "elpaca-menu-lock-file" :recipe
    (:package "dash" :fetcher github :repo "magnars/dash.el" :files ("dash.el" "dash.texi") :source
      "elpaca-menu-lock-file" :id dash :type git :protocol https :inherit t :depth treeless :ref
      "d3a84021dbe48dba63b52ef7665651e0cf02e915"))
  (dashboard :source "elpaca-menu-lock-file" :recipe
    (:package "dashboard" :fetcher github :repo "emacs-dashboard/dashboard" :files (:defaults "banners") :source
      "elpaca-menu-lock-file" :id dashboard :type git :protocol https :inherit t :depth treeless :ref
      "176d641a55543bda1f0c7506fb954702350c1857"))
  (dired-filter :source "elpaca-menu-lock-file" :recipe
    (:package "dired-filter" :fetcher github :repo "Fuco1/dired-hacks" :files ("dired-filter.el") :source
      "elpaca-menu-lock-file" :id dired-filter :type git :protocol https :inherit t :depth treeless :ref
      "de9336f4b47ef901799fe95315fa080fa6d77b48"))
  (dired-hacks-utils :source "elpaca-menu-lock-file" :recipe
    (:package "dired-hacks-utils" :fetcher github :repo "Fuco1/dired-hacks" :files ("dired-hacks-utils.el") :source
      "elpaca-menu-lock-file" :id dired-hacks-utils :type git :protocol https :inherit t :depth treeless :ref
      "de9336f4b47ef901799fe95315fa080fa6d77b48"))
  (dired-sidebar :source "elpaca-menu-lock-file" :recipe
    (:package "dired-sidebar" :fetcher github :repo "jojojames/dired-sidebar" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id dired-sidebar :type git :protocol https :inherit t :depth treeless :ref
      "19cdf0b9ed634efb7ae7047861fbcbd9dc0ee2e9"))
  (dired-subtree :source "elpaca-menu-lock-file" :recipe
    (:package "dired-subtree" :fetcher github :repo "Fuco1/dired-hacks" :files ("dired-subtree.el") :source
      "elpaca-menu-lock-file" :id dired-subtree :type git :protocol https :inherit t :depth treeless :ref
      "de9336f4b47ef901799fe95315fa080fa6d77b48"))
  (doom-modeline :source "elpaca-menu-lock-file" :recipe
    (:package "doom-modeline" :repo "seagle0128/doom-modeline" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id doom-modeline :type git :protocol https :inherit t :depth treeless :ref
      "871f91fad58aefa9e549cbff1929e0dd328021c7"))
  (doom-themes :source "elpaca-menu-lock-file" :recipe
    (:package "doom-themes" :fetcher github :repo "doomemacs/themes" :files
      (:defaults "themes/*.el" "themes/*/*.el" "extensions/*.el") :source "elpaca-menu-lock-file" :id doom-themes :type
      git :protocol https :inherit t :depth treeless :ref "53645a905dfb3055db52f5d418d5ef612027e062"))
  (dotenv-mode :source "elpaca-menu-lock-file" :recipe
    (:package "dotenv-mode" :repo "preetpalS/emacs-dotenv-mode" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id dotenv-mode :type git :protocol https :inherit t :depth treeless :ref
      "e3701bf739bde44f6484eb7753deadaf691b73fb"))
  (eat :source "elpaca-menu-lock-file" :recipe
    (:package "eat" :repo ("https://codeberg.org/akib/emacs-eat" . "eat") :tar "0.9.4" :host nongnu :files
      ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id eat :type git :protocol https :inherit t :depth
      treeless :ref "c8d54d649872bfe7b2b9f49ae5c2addbf12d3b99"))
  (eglot-signature-eldoc-talkative :source "elpaca-menu-lock-file" :recipe
    (:package "eglot-signature-eldoc-talkative" :fetcher codeberg :repo "mekeor/eglot-signature-eldoc-talkative" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id eglot-signature-eldoc-talkative :type git :protocol https :inherit t :depth
      treeless :ref "3a003eb5cb366d3ec93d51a848bdfce9a6846174"))
  (el-patch :source "elpaca-menu-lock-file" :recipe
    (:package "el-patch" :fetcher github :repo "radian-software/el-patch" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id el-patch :wait t :type git :protocol https :inherit t :depth treeless :ref
      "5adb7097d0ff3d9e004a8bb07c0b25f7ee20ba8a"))
  (elisp-refs :source "elpaca-menu-lock-file" :recipe
    (:package "elisp-refs" :repo "Wilfred/elisp-refs" :fetcher github :files
      (:defaults (:exclude "elisp-refs-bench.el")) :source "elpaca-menu-lock-file" :id elisp-refs :type git :protocol
      https :inherit t :depth treeless :ref "541a064c3ce27867872cf708354a65d83baf2a6d"))
  (elpaca :source
    "elpaca-menu-lock-file" :recipe
    (:source nil :package "elpaca" :id elpaca :repo "https://github.com/progfolio/elpaca.git" :ref
      "27c2889f66368bde12b4e243582e343ed9cb75e3" :depth 1 :inherit ignore :files
      (:defaults "elpaca-test.el" (:exclude "extensions")) :build (:not elpaca-activate) :type git :protocol https))
  (elpaca-use-package :source "elpaca-menu-lock-file" :recipe
    (:package "elpaca-use-package" :wait t :repo "https://github.com/progfolio/elpaca.git" :files
      ("extensions/elpaca-use-package.el") :main "extensions/elpaca-use-package.el" :build (:not elpaca-build-docs)
      :source "elpaca-menu-lock-file" :id elpaca-use-package :type git :protocol https :inherit t :depth treeless :ref
      "27c2889f66368bde12b4e243582e343ed9cb75e3"))
  (embark :source "elpaca-menu-lock-file" :recipe
    (:package "embark" :repo "oantolin/embark" :fetcher github :files ("embark.el" "embark-org.el" "embark.texi")
      :source "elpaca-menu-lock-file" :id embark :type git :protocol https :inherit t :depth treeless :ref
      "c3774e93d9ff73973c7536730d0a2255dbb6cd1d"))
  (embark-consult :source "elpaca-menu-lock-file" :recipe
    (:package "embark-consult" :repo "oantolin/embark" :fetcher github :files ("embark-consult.el") :source
      "elpaca-menu-lock-file" :id embark-consult :type git :protocol https :inherit t :depth treeless :ref
      "c3774e93d9ff73973c7536730d0a2255dbb6cd1d"))
  (emmet-mode :source "elpaca-menu-lock-file" :recipe
    (:package "emmet-mode" :fetcher github :repo "smihica/emmet-mode" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id emmet-mode :type git :protocol https :inherit t :depth treeless :ref
      "322d3bb112fced57d63b44863357f7a0b7eee1e3"))
  (envrc :source "elpaca-menu-lock-file" :recipe
    (:package "envrc" :fetcher github :repo "purcell/envrc" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id envrc :type git :protocol https :inherit t :depth treeless :ref
      "1e63a3db367254897a39251944ba68938ec41020"))
  (erlang :source "elpaca-menu-lock-file" :recipe
    (:package "erlang" :fetcher github :repo "erlang/otp" :version-regexp "OTP-%v" :files
      ("lib/tools/emacs/*.el" (:exclude "lib/tools/emacs/erlang_appwiz.el")) :source "elpaca-menu-lock-file" :id erlang
      :type git :protocol https :inherit t :depth treeless :ref "a87b88ccf1e546dea45b0ca82374a8226d8074b0"))
  (exec-path-from-shell :source "elpaca-menu-lock-file" :recipe
    (:package "exec-path-from-shell" :fetcher github :repo "purcell/exec-path-from-shell" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id exec-path-from-shell :wait t :type git :protocol https :inherit t :depth
      treeless :ref "58b33fefdcd90726c3ea7175b2abc68eccae46e1"))
  (exunit :source "elpaca-menu-lock-file" :recipe
    (:package "exunit" :fetcher github :repo "ananthakumaran/exunit.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id exunit :type git :protocol https :inherit t :depth treeless :ref
      "bef971bde5634992fc2e4c8436b3feaddd8d7ed6"))
  (f :source "elpaca-menu-lock-file" :recipe
    (:package "f" :fetcher github :repo "rejeep/f.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id f :type git :protocol https :inherit t :depth treeless :ref
      "931b6d0667fe03e7bf1c6c282d6d8d7006143c52"))
  (flymake :source "elpaca-menu-lock-file" :recipe
    (:package "flymake" :repo ("https://github.com/emacs-mirror/emacs" . "flymake") :tar "1.4.5" :host gnu :branch
      "master" :files
      ("lisp/progmodes/flymake.el" "doc/emacs/doclicense.texi" "doc/emacs/docstyle.texi" "doc/misc/flymake.texi"
        (:exclude ".git"))
      :source "elpaca-menu-lock-file" :id flymake :type git :protocol https :inherit t :depth treeless :ref
      "d70c646894addec51b4948425b4a3779f761317f"))
  (flymake-collection :source "elpaca-menu-lock-file" :recipe
    (:package "flymake-collection" :fetcher github :repo "mohkale/flymake-collection" :files
      (:defaults "src/*.el" "src/checkers/*.el") :old-names (flymake-rest) :source "elpaca-menu-lock-file" :id
      flymake-collection :type git :protocol https :inherit t :depth treeless :ref
      "909d98d9ec70c2baa5467634ec37181a058f2548"))
  (ghostel :source "elpaca-menu-lock-file" :recipe
    (:package "ghostel" :fetcher github :repo "dakra/ghostel" :files
      (:defaults "etc" "src" "vendor" "build.zig" "build.zig.zon" "symbols.map") :source "elpaca-menu-lock-file" :id
      ghostel :type git :protocol https :inherit t :depth treeless :ref "d3e30721741248b24341914e1e7dad6b71d3805f"))
  (git-link :source "elpaca-menu-lock-file" :recipe
    (:package "git-link" :fetcher github :repo "sshaw/git-link" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id git-link :host github :type git :protocol https :inherit t :depth treeless
      :ref "ca1a170343448c6d5d265ec12f934d865f7e0aee"))
  (git-modes :source "elpaca-menu-lock-file" :recipe
    (:package "git-modes" :fetcher github :repo "magit/git-modes" :old-names
      (gitattributes-mode gitconfig-mode gitignore-mode) :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id git-modes :type git :protocol https :inherit t :depth treeless :ref
      "8c6e5b01feddd0c3da624941c8a4b20bb60f3656"))
  (helpful :source "elpaca-menu-lock-file" :recipe
    (:package "helpful" :repo "Wilfred/helpful" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id helpful :type git :protocol https :inherit t :depth treeless :ref
      "03756fa6ad4dcca5e0920622b1ee3f70abfc4e39"))
  (ht :source "elpaca-menu-lock-file" :recipe
    (:package "ht" :fetcher github :repo "Wilfred/ht.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id ht :type git :protocol https :inherit t :depth treeless :ref
      "1c49aad1c820c86f7ee35bf9fff8429502f60fef"))
  (iedit :source "elpaca-menu-lock-file" :recipe
    (:package "iedit" :repo "victorhge/iedit" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id iedit :type git :protocol https :inherit t :depth treeless :ref
      "14161daa295332a49dda92b97c00d62efd38acfe"))
  (indent-bars :source "elpaca-menu-lock-file" :recipe
    (:package "indent-bars" :repo ("https://github.com/jdtsmith/indent-bars" . "indent-bars") :tar "1.0.0" :host gnu
      :files ("*" (:exclude ".git" "LICENSE")) :source "elpaca-menu-lock-file" :id indent-bars :type git :protocol https
      :inherit t :depth treeless :ref "f95fee11d9932cba71d686807025239be0319e91"))
  (inf-elixir :source "elpaca-menu-lock-file" :recipe
    (:package "inf-elixir" :fetcher github :repo "J3RN/inf-elixir" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id inf-elixir :type git :protocol https :inherit t :depth treeless :ref
      "085f1c198a121c569a161f9fa71e6cce1998cd63"))
  (inf-ruby :source "elpaca-menu-lock-file" :recipe
    (:package "inf-ruby" :repo "nonsequitur/inf-ruby" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id inf-ruby :type git :protocol https :inherit t :depth treeless :ref
      "274398a24288a7db430a656b580ffbf889ca02aa"))
  (inflections :source "elpaca-menu-lock-file" :recipe
    (:package "inflections" :repo "eschulte/jump.el" :fetcher github :files ("inflections.el") :source
      "elpaca-menu-lock-file" :id inflections :type git :protocol https :inherit t :depth treeless :ref
      "55caa66a7cc6e0b1a76143fd40eff38416928941"))
  (inheritenv :source "elpaca-menu-lock-file" :recipe
    (:package "inheritenv" :fetcher github :repo "purcell/inheritenv" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id inheritenv :type git :protocol https :inherit t :depth treeless :ref
      "b9e67cc20c069539698a9ac54d0e6cc11e616c6f"))
  (journalctl-mode :source "elpaca-menu-lock-file" :recipe
    (:package "journalctl-mode" :fetcher github :repo "SebastianMeisel/journalctl-mode" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id journalctl-mode :type git :protocol https :inherit t :depth treeless :ref
      "0b9294f8f2b53375aa4f4fb3eb7f73be7cd15add"))
  (kdl-mode :source "elpaca-menu-lock-file" :recipe
    (:package "kdl-mode" :fetcher github :repo "taquangtrung/emacs-kdl-mode" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id kdl-mode :type git :protocol https :inherit t :depth treeless :ref
      "2d849e298199f490e4894c01764a8a83decd704a"))
  (ligature :source "elpaca-menu-lock-file" :recipe
    (:package "ligature" :fetcher github :repo "mickeynp/ligature.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id ligature :type git :protocol https :inherit t :depth treeless :ref
      "6ac1634612dbd42f7eb81ecaf022bd239aabb954"))
  (llama :source "elpaca-menu-lock-file" :recipe
    (:package "llama" :fetcher github :repo "tarsius/llama" :files ("llama.el" ".dir-locals.el") :source
      "elpaca-menu-lock-file" :id llama :type git :protocol https :inherit t :depth treeless :ref
      "e6d2127c12d43a923b86341cb160c8c23c3a2e0d"))
  (magit :source "elpaca-menu-lock-file" :recipe
    (:package "magit" :fetcher github :repo "magit/magit" :files
      ("lisp/magit*.el" "lisp/git-*.el" "docs/magit.texi" "docs/AUTHORS.md" "LICENSE" ".dir-locals.el"
        ("git-hooks" "git-hooks/*") (:exclude "lisp/magit-section.el"))
      :source "elpaca-menu-lock-file" :id magit :type git :protocol https :inherit t :depth treeless :ref
      "a9fd4a914ba87da7258fd26946693f282a407885"))
  (magit-delta :source "elpaca-menu-lock-file" :recipe
    (:package "magit-delta" :fetcher github :repo "dandavison/magit-delta" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id magit-delta :type git :protocol https :inherit t :depth treeless :ref
      "5fc7dbddcfacfe46d3fd876172ad02a9ab6ac616"))
  (magit-section :source "elpaca-menu-lock-file" :recipe
    (:package "magit-section" :fetcher github :repo "magit/magit" :files
      ("lisp/magit-section.el" "docs/magit-section.texi" "magit-section-pkg.el") :source "elpaca-menu-lock-file" :id
      magit-section :type git :protocol https :inherit t :depth treeless :ref "a9fd4a914ba87da7258fd26946693f282a407885"))
  (marginalia :source "elpaca-menu-lock-file" :recipe
    (:package "marginalia" :repo "minad/marginalia" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id marginalia :type git :protocol https :inherit t :depth treeless :ref
      "feb66c02bbd88dba867cdd92b94fe24279ed578a"))
  (markdown-mode :source "elpaca-menu-lock-file" :recipe
    (:package "markdown-mode" :fetcher github :repo "jrblevin/markdown-mode" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id markdown-mode :type git :protocol https :inherit t :depth treeless :ref
      "1f72cefa6a4b759f90e335e4908725a721b17ad9"))
  (memoize :source "elpaca-menu-lock-file" :recipe
    (:package "memoize" :repo "skeeto/emacs-memoize" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id memoize :type git :protocol https :inherit t :depth treeless :ref
      "51b075935ca7070f62fae1d69fe0ff7d8fa56fdd"))
  (meow :source "elpaca-menu-lock-file" :recipe
    (:package "meow" :repo "meow-edit/meow" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id meow :type git :protocol https :inherit t :depth treeless :ref
      "2246f593552c6208bac533de9af04b085fafa6fa"))
  (meow-tree-sitter :source "elpaca-menu-lock-file" :recipe
    (:package "meow-tree-sitter" :fetcher github :repo "skissue/meow-tree-sitter" :files (:defaults "queries") :source
      "elpaca-menu-lock-file" :id meow-tree-sitter :type git :protocol https :inherit t :depth treeless :ref
      "f050dc0867b7a37efc2c6432b33305a0f14b1029"))
  (minions :source "elpaca-menu-lock-file" :recipe
    (:package "minions" :fetcher github :repo "tarsius/minions" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id minions :type git :protocol https :inherit t :depth treeless :ref
      "97392223bbdad004cd8d2e8039833ecb961d7728"))
  (mix :source "elpaca-menu-lock-file" :recipe
    (:package "mix" :fetcher github :repo "ayrat555/mix.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id mix :type git :protocol https :inherit t :depth treeless :ref
      "16cc69cbf919769c191b1c49c1cab324fd0682a9"))
  (msgpack :source "elpaca-menu-lock-file" :recipe
    (:package "msgpack" :fetcher github :repo "xuchunyang/msgpack.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id msgpack :type git :protocol https :inherit t :depth treeless :ref
      "90e3086f259549b1667a3c5b9aa2d70aaeaa4d3d"))
  (nerd-icons :source "elpaca-menu-lock-file" :recipe
    (:package "nerd-icons" :repo "rainstormstudio/nerd-icons.el" :fetcher github :files (:defaults "data") :source
      "elpaca-menu-lock-file" :id nerd-icons :type git :protocol https :inherit t :depth treeless :ref
      "d33d12f5dcb6bf2fb23c3f75df5de85beb4afd95"))
  (nerd-icons-completion :source "elpaca-menu-lock-file" :recipe
    (:package "nerd-icons-completion" :repo "rainstormstudio/nerd-icons-completion" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id nerd-icons-completion :type git :protocol https :inherit t :depth treeless
      :ref "45b585d972192a3eaeb239e15e55de7f46f8920a"))
  (nerd-icons-corfu :source "elpaca-menu-lock-file" :recipe
    (:package "nerd-icons-corfu" :fetcher github :repo "LuigiPiucco/nerd-icons-corfu" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id nerd-icons-corfu :type git :protocol https :inherit t :depth treeless :ref
      "f821e953b1a3dc9b381bc53486aabf366bf11cb1"))
  (nerd-icons-dired :source "elpaca-menu-lock-file" :recipe
    (:package "nerd-icons-dired" :repo "rainstormstudio/nerd-icons-dired" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id nerd-icons-dired :type git :protocol https :inherit t :depth treeless :ref
      "104acd8879528b8115589f35f1bbcbe231ad732f"))
  (nerd-icons-ibuffer :source "elpaca-menu-lock-file" :recipe
    (:package "nerd-icons-ibuffer" :repo "seagle0128/nerd-icons-ibuffer" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id nerd-icons-ibuffer :type git :protocol https :inherit t :depth treeless :ref
      "13007b941ebfa471122f0658a2315040b8eb4aa4"))
  (ns-auto-titlebar :source "elpaca-menu-lock-file" :recipe
    (:package "ns-auto-titlebar" :fetcher github :repo "purcell/ns-auto-titlebar" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id ns-auto-titlebar :type git :protocol https :inherit t :depth treeless :ref
      "1205ac67b76b58e9eb53d2115b85775533653a80"))
  (orderless :source "elpaca-menu-lock-file" :recipe
    (:package "orderless" :repo "oantolin/orderless" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id orderless :type git :protocol https :inherit t :depth treeless :ref
      "09c90d93efce4fdac52edfe8b22591b773f3e607"))
  (osx-trash :source "elpaca-menu-lock-file" :recipe
    (:package "osx-trash" :fetcher github :repo "emacsorphanage/osx-trash" :files (:defaults "*.AppleScript") :source
      "elpaca-menu-lock-file" :id osx-trash :type git :protocol https :inherit t :depth treeless :ref
      "90f0c99206022fec646206018fcd63d9d2e57325"))
  (otpp :source "elpaca-menu-lock-file" :recipe
    (:package "otpp" :fetcher github :repo "abougouffa/one-tab-per-project" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id otpp :type git :protocol https :inherit t :depth treeless :ref
      "95510a72fc167886b60135fbecf4bbed5fed5515"))
  (popper :source "elpaca-menu-lock-file" :recipe
    (:package "popper" :fetcher github :repo "karthink/popper" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id popper :type git :protocol https :inherit t :depth treeless :ref
      "d83b894ee7a9daf7c8e9b864c23d08f1b23d78f6"))
  (prescient :source "elpaca-menu-lock-file" :recipe
    (:package "prescient" :fetcher github :repo "radian-software/prescient.el" :files ("prescient.el") :source
      "elpaca-menu-lock-file" :id prescient :type git :protocol https :inherit t :depth treeless :ref
      "87e2d2f2ddf24f591a5f70cc90d2afb4537caa18"))
  (project :source "elpaca-menu-lock-file" :recipe
    (:package "project" :repo ("https://github.com/emacs-mirror/emacs" . "project") :tar "0.11.2" :host gnu :branch
      "master" :files ("lisp/progmodes/project.el" (:exclude ".git")) :source "elpaca-menu-lock-file" :id project :type
      git :protocol https :inherit t :depth treeless :ref "d70c646894addec51b4948425b4a3779f761317f"))
  (rails-i18n :source "elpaca-menu-lock-file" :recipe
    (:package "rails-i18n" :repo "otavioschwanck/rails-i18n.el" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id rails-i18n :type git :protocol https :inherit t :depth treeless :ref
      "8e87e4e48e31902b8259ded28a208c2e7efea6e9"))
  (rails-routes :source "elpaca-menu-lock-file" :recipe
    (:package "rails-routes" :repo "otavioschwanck/rails-routes.el" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id rails-routes :type git :protocol https :inherit t :depth treeless :ref
      "eab995a9297ca5bd9bd4f4c2737f2fecfc36def0"))
  (rainbow-csv :source "elpaca-menu-lock-file" :recipe
    (:source "elpaca-menu-lock-file" :package "rainbow-csv" :id rainbow-csv :host github :repo "emacs-vs/rainbow-csv"
      :type git :protocol https :inherit t :depth treeless :ref "5b0bbaca8c6c1785b5ddd48fdf16817acc046ad2"))
  (rpm-spec-mode :source "elpaca-menu-lock-file" :recipe
    (:package "rpm-spec-mode" :fetcher github :repo "Thaodan/rpm-spec-mode" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id rpm-spec-mode :type git :protocol https :inherit t :depth treeless :ref
      "90c1beceff24b9f0e02c5a141efd466d5763f957"))
  (rspec-mode :source "elpaca-menu-lock-file" :recipe
    (:package "rspec-mode" :repo "pezra/rspec-mode" :fetcher github :files ("rspec-mode.el" "snippets") :source
      "elpaca-menu-lock-file" :id rspec-mode :type git :protocol https :inherit t :depth treeless :ref
      "29df3d081c6a1cbdf840cd13d45ea1c100c5bbaa"))
  (rust-mode :source "elpaca-menu-lock-file" :recipe
    (:package "rust-mode" :repo "rust-lang/rust-mode" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id rust-mode :type git :protocol https :inherit t :depth treeless :ref
      "ed401a65743359b8de11ee9ced0e1da39946cefd"))
  (s :source "elpaca-menu-lock-file" :recipe
    (:package "s" :fetcher github :repo "magnars/s.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id s :type git :protocol https :inherit t :depth treeless :ref
      "7393fa6fa305403e628058c0ec78c35d610fab05"))
  (scratch :source "elpaca-menu-lock-file" :recipe
    (:package "scratch" :fetcher codeberg :repo "emacs-weirdware/scratch" :files ("scratch.el") :source
      "elpaca-menu-lock-file" :id scratch :type git :protocol https :inherit t :depth treeless :ref
      "f000648c9663833a76a8de9b1e78c99a9d698e48"))
  (shell-maker :source "elpaca-menu-lock-file" :recipe
    (:package "shell-maker" :fetcher github :repo "xenodium/shell-maker" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id shell-maker :type git :protocol https :inherit t :depth treeless :ref
      "904f8dcb1164291c2486048e19ed76fd60062e90"))
  (shrink-path :source "elpaca-menu-lock-file" :recipe
    (:package "shrink-path" :fetcher gitlab :repo "bennya/shrink-path.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id shrink-path :type git :protocol https :inherit t :depth treeless :ref
      "c14882c8599aec79a6e8ef2d06454254bb3e1e41"))
  (sideline :source "elpaca-menu-lock-file" :recipe
    (:package "sideline" :repo "emacs-sideline/sideline" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id sideline :type git :protocol https :inherit t :depth treeless :ref
      "b4ada1ddf7da96c2e87453130f6ff7b7d577810f"))
  (sideline-eglot :source "elpaca-menu-lock-file" :recipe
    (:package "sideline-eglot" :fetcher github :repo "emacs-sideline/sideline-eglot" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id sideline-eglot :type git :protocol https :inherit t :depth treeless :ref
      "aeb1991a7f25301438806a06c588e7e732c6f533"))
  (sideline-flymake :source "elpaca-menu-lock-file" :recipe
    (:package "sideline-flymake" :repo "emacs-sideline/sideline-flymake" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id sideline-flymake :type git :protocol https :inherit t :depth treeless :ref
      "ad296589a97ad7225f3f1e9519443577b2c5a49b"))
  (solaire-mode :source "elpaca-menu-lock-file" :recipe
    (:package "solaire-mode" :repo "hlissner/emacs-solaire-mode" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id solaire-mode :type git :protocol https :inherit t :depth treeless :ref
      "1bd0134194e48c8fe4089e9d505517935b2b15e3"))
  (stripspace :source "elpaca-menu-lock-file" :recipe
    (:package "stripspace" :fetcher github :repo "jamescherti/stripspace.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id stripspace :type git :protocol https :inherit t :depth treeless :ref
      "e2ee32a5eca29218b621a77f580c83111eb5d160"))
  (sudo-edit :source "elpaca-menu-lock-file" :recipe
    (:package "sudo-edit" :repo "nflath/sudo-edit" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id sudo-edit :type git :protocol https :inherit t :depth treeless :ref
      "74eb1e6986461baed9a9269566ff838530b4379b"))
  (svelte-ts-mode :source "elpaca-menu-lock-file" :recipe
    (:source "elpaca-menu-lock-file" :package "svelte-ts-mode" :id svelte-ts-mode :host github :repo
      "leafOfTree/svelte-ts-mode" :type git :protocol https :inherit t :depth treeless :ref
      "d079050fc1ba70f8fba9e596638daa2ca96e0fdd"))
  (system-packages :source "elpaca-menu-lock-file" :recipe
    (:package "system-packages" :repo ("https://gitlab.com/jabranham/system-packages" . "system-packages") :tar "1.1.2"
      :host gnu :files ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id system-packages :type git :protocol
      https :inherit t :depth treeless :ref "de2a98caad223ded3b58512d8f44a8307a228a93"))
  (systemd :source "elpaca-menu-lock-file" :recipe
    (:package "systemd" :fetcher github :repo "mavit/systemd-mode" :files (:defaults "*.txt") :source
      "elpaca-menu-lock-file" :id systemd :host github :branch "podman" :type git :protocol https :inherit t :depth
      treeless :ref "63f7c377f1bf72f91fa940e6f9c8e0717a64a44b"))
  (track-changes :source "elpaca-menu-lock-file" :recipe
    (:package "track-changes" :repo ("https://github.com/emacs-mirror/emacs" . "track-changes") :tar "1.5" :host gnu
      :branch "master" :files ("lisp/emacs-lisp/track-changes.el" (:exclude ".git")) :source "elpaca-menu-lock-file" :id
      track-changes :type git :protocol https :inherit t :depth treeless :ref "d70c646894addec51b4948425b4a3779f761317f"))
  (tramp :source "elpaca-menu-lock-file" :recipe
    (:package "tramp" :repo ("https://git.savannah.gnu.org/git/tramp.git" . "tramp") :tar "2.8.1.4" :host gnu :branch
      "externals/tramp" :files ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id tramp :type git :protocol
      https :inherit t :depth treeless :ref "8283083697197d4f6e36c265253471441350892d"))
  (tramp-rpc :source "elpaca-menu-lock-file" :recipe
    (:source "elpaca-menu-lock-file" :package "tramp-rpc" :id tramp-rpc :repo
      "https://github.com/ArthurHeymans/emacs-tramp-rpc" :files ("lisp/*.el" :defaults) :type git :protocol https
      :inherit t :depth treeless :ref "098547393ee8fb8caea1b55b4d713dd96f88dd85"))
  (transient :source "elpaca-menu-lock-file" :recipe
    (:package "transient" :fetcher github :repo "magit/transient" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id transient :type git :protocol https :inherit t :depth treeless :ref
      "e39ecb46672f96b33c8c5a857a969da56d2438e8"))
  (treesit-auto :source "elpaca-menu-lock-file" :recipe
    (:package "treesit-auto" :fetcher github :repo "renzmann/treesit-auto" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id treesit-auto :type git :protocol https :inherit t :depth treeless :ref
      "31466e4ccfd4f896ce3145c95c4c1f8b59d4bfdf"))
  (treesit-fold :source "elpaca-menu-lock-file" :recipe
    (:package "treesit-fold" :repo ("https://github.com/emacs-tree-sitter/treesit-fold" . "treesit-fold") :tar "0.2.1"
      :host nongnu :files ("*" (:exclude ".git")) :source "elpaca-menu-lock-file" :id treesit-fold :type git :protocol
      https :inherit t :depth treeless :ref "e6b215b8f25f8c58606ab4f850794b61b61111e1"))
  (ultra-scroll :source "elpaca-menu-lock-file" :recipe
    (:package "ultra-scroll" :fetcher github :repo "jdtsmith/ultra-scroll" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id ultra-scroll :host github :type git :protocol https :inherit t :depth treeless
      :ref "f38653053b5c9bbe8dbcb6b2236ab8997fc2f9bb"))
  (undo-fu :source "elpaca-menu-lock-file" :recipe
    (:package "undo-fu" :fetcher codeberg :repo "ideasman42/emacs-undo-fu" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id undo-fu :type git :protocol https :inherit t :depth treeless :ref
      "5684ef2aef5f60176472916b21869cf221e018cc"))
  (undo-fu-session :source "elpaca-menu-lock-file" :recipe
    (:package "undo-fu-session" :fetcher codeberg :repo "ideasman42/emacs-undo-fu-session" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id undo-fu-session :type git :protocol https :inherit t :depth treeless :ref
      "92d733a5b162a70c572fac17b9f9e872426df547"))
  (verb :source "elpaca-menu-lock-file" :recipe
    (:package "verb" :repo "federicotdn/verb" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id verb :type git :protocol https :inherit t :depth treeless :ref
      "81aa67dffb17b3d88b35f16787aa3292d5761abb"))
  (vertico :source "elpaca-menu-lock-file" :recipe
    (:package "vertico" :repo "minad/vertico" :files (:defaults "extensions/vertico-*.el") :fetcher github :source
      "elpaca-menu-lock-file" :id vertico :type git :protocol https :inherit t :depth treeless :ref
      "6e45be6105819297da8472dd8f37a38eb4a0b6e5"))
  (vertico-prescient :source "elpaca-menu-lock-file" :recipe
    (:package "vertico-prescient" :fetcher github :repo "radian-software/prescient.el" :files ("vertico-prescient.el")
      :source "elpaca-menu-lock-file" :id vertico-prescient :type git :protocol https :inherit t :depth treeless :ref
      "87e2d2f2ddf24f591a5f70cc90d2afb4537caa18"))
  (vim-tab-bar :source "elpaca-menu-lock-file" :recipe
    (:package "vim-tab-bar" :fetcher github :repo "jamescherti/vim-tab-bar.el" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id vim-tab-bar :type git :protocol https :inherit t :depth treeless :ref
      "28d0177531433772e7c7b05cd9d7b913b67ed8b6"))
  (visual-fill-column :source "elpaca-menu-lock-file" :recipe
    (:package "visual-fill-column" :fetcher codeberg :repo "joostkremers/visual-fill-column" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id visual-fill-column :type git :protocol https :inherit t :depth treeless :ref
      "e1be9a1545157d24454d950c0ac79553c540edb7"))
  (vundo :source "elpaca-menu-lock-file" :recipe
    (:package "vundo" :repo ("https://github.com/casouri/vundo" . "vundo") :tar "2.4.0" :host gnu :files
      ("*" (:exclude ".git" "test")) :source "elpaca-menu-lock-file" :id vundo :type git :protocol https :inherit t
      :depth treeless :ref "e0af8c5845abf884a644215a9cac37f39c13cd5a"))
  (web-mode :source "elpaca-menu-lock-file" :recipe
    (:package "web-mode" :repo "fxbois/web-mode" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id web-mode :type git :protocol https :inherit t :depth treeless :ref
      "e93b3fb89fd6345a5ff59795bed712abd486200a"))
  (wgrep :source "elpaca-menu-lock-file" :recipe
    (:package "wgrep" :fetcher github :repo "mhayashi1120/Emacs-wgrep" :files ("wgrep.el") :source
      "elpaca-menu-lock-file" :id wgrep :type git :protocol https :inherit t :depth treeless :ref
      "49f09ab9b706d2312cab1199e1eeb1bcd3f27f6f"))
  (winpulse :source "elpaca-menu-lock-file" :recipe
    (:package "winpulse" :fetcher github :repo "xenodium/winpulse" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id winpulse :type git :protocol https :inherit t :depth treeless :ref
      "c58352bea2223fd6f0cc11deb4d33bca2ff0213c"))
  (with-editor :source "elpaca-menu-lock-file" :recipe
    (:package "with-editor" :fetcher github :repo "magit/with-editor" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id with-editor :type git :protocol https :inherit t :depth treeless :ref
      "e1ab360024404fe6548505ab76616cfc42edf0cc"))
  (ws-butler :source "elpaca-menu-lock-file" :recipe
    (:package "ws-butler" :fetcher git :url "https://https.git.savannah.gnu.org/git/elpa/nongnu.git" :branch
      "elpa/ws-butler" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id ws-butler :type git :protocol https :inherit t :depth treeless :ref
      "67c49cfdf5a5a9f28792c500c8eb0017cfe74a3a"))
  (xterm-color :source "elpaca-menu-lock-file" :recipe
    (:package "xterm-color" :repo "atomontage/xterm-color" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id xterm-color :type git :protocol https :inherit t :depth treeless :ref
      "86fab1d247eb5ebe6b40fa5073a70dfa487cd465"))
  (yaml :source "elpaca-menu-lock-file" :recipe
    (:package "yaml" :repo "zkry/yaml.el" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id yaml :type git :protocol https :inherit t :depth treeless :ref
      "f2369fb4985ed054be47ae111760ff2075dff72a"))
  (yasnippet :source "elpaca-menu-lock-file" :recipe
    (:package "yasnippet" :fetcher github :repo "joaotavora/yasnippet" :files (:defaults ("doc" "doc/*.org")) :source
      "elpaca-menu-lock-file" :id yasnippet :type git :protocol https :inherit t :depth treeless :ref
      "c1e6ff23e9af16b856c88dfaab9d3ad7b746ad37"))
  (yasnippet-capf :source "elpaca-menu-lock-file" :recipe
    (:package "yasnippet-capf" :fetcher github :repo "elken/yasnippet-capf" :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id yasnippet-capf :host github :type git :protocol https :inherit t :depth
      treeless :ref "f53c42a996b86fc95b96bdc2deeb58581f48c666"))
  (yasnippet-snippets :source "elpaca-menu-lock-file" :recipe
    (:package "yasnippet-snippets" :repo "AndreaCrotti/yasnippet-snippets" :fetcher github :files
      ("*.el" "snippets" ".nosearch") :source "elpaca-menu-lock-file" :id yasnippet-snippets :type git :protocol https
      :inherit t :depth treeless :ref "606ee926df6839243098de6d71332a697518cb86"))
  (zoom :source "elpaca-menu-lock-file" :recipe
    (:package "zoom" :repo "cyrus-and/zoom" :fetcher github :files
      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
        (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el" "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
      :source "elpaca-menu-lock-file" :id zoom :type git :protocol https :inherit t :depth treeless :ref
      "5e524d98c7f2b4dd6ed41d95573b29b263632eb2")))
