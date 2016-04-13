#!/usr/bin/env bash
ocamlbuild -use-ocamlfind -package compiler-libs.common,js_of_ocaml.ppx.internal ppx.byte
