{
  buildPythonApplication,
  lib,
  fetchFromGitHub,
  appdirs,
  click,
  colorama,
  intelhex,
  packaging,
  pyaml,
  pyftdi,
  pyserial,
  requests,
  schema,
}:
buildPythonApplication rec {
  pname = "bigclown-firmware-tool";
  version = "1.9.0";
  meta = with lib; {
    homepage = "https://github.com/hardwario/bch-firmware-tool";
    description = "HARDWARIO Firmware Tool";
    platforms = platforms.linux;
    license = licenses.mit;
  };

  propagatedBuildInputs = [
    appdirs
    click
    colorama
    intelhex
    packaging
    pyaml
    pyftdi
    pyserial
    requests
    schema
  ];

  postPatch = ''
    sed -ri 's/@@VERSION@@/${version}/g' \
      bcf/__init__.py setup.py
  '';

  doCheck = false;
  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-firmware-tool";
    rev = "v${version}";
    sha256 = "i28VewTB2XEZSfk0UeCuwB7Z2wz4qPBhzvxJIYkKwJ4=";
  };
}
