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
    homepage = "https://github.com/hardwario/bch-mqtt2influxdb";
    description = "Flexible MQTT to InfluxDB Bridge";
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

  doCheck = false;
  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-firmware-tool";
    rev = "v${version}";
    sha256 = "i28VewTB2XEZSfk0UeCuwB7Z2wz4qPBhzvxJIYkKwJ4=";
  };
}
