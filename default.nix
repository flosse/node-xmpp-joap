{ pkgs ? import <nixpkgs> {} }:

let
  nodePackages = pkgs.nodePackages.override {
    self = nodePackages;
    generated = ./node-packages.nix;
  };

in pkgs.stdenv.mkDerivation rec {
  name = "dev-env";
  src = ./.;
  buildInputs = with nodePackages; [
    pkgs.utillinux
    pkgs.python
    pkgs.stdenv
    pkgs.nodejs
    coffee-script
    chai
    mocha
    sinon-chai
    sinon
  ]
  ++
  [
    async
    ltx
    node-expat
    node-stringprep
    node-uuid
    node-xmpp-core
    toobusy-js
  ];
}
