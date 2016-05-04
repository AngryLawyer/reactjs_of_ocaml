# Edit this for your own project dependencies
OPAM_DEPENDS="ocamlfind js_of_ocaml alcotest"

case "$OCAML_VERSION,$OPAM_VERSION" in
4.02.3,1.2.2) ppa=avsm/ocaml42+opam12 ;;
*) echo Unknown $OCAML_VERSION,$OPAM_VERSION; exit 1 ;;
esac

echo "yes" | sudo add-apt-repository ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam
export OPAMYES=1
opam init
opam install ${OPAM_DEPENDS}
eval `opam config env`

# commonjs_of_ocaml isn't on opam yet, so install it here
git clone https://github.com/AngryLawyer/commonjs_of_ocaml.git
cd commonjs_of_ocaml
ocaml setup.ml -configure
ocaml setup.ml -build
ocaml setup.ml -install
cd -

ocaml setup.ml -configure --enable-tests
ocaml setup.ml -build
ocaml setup.ml -test
