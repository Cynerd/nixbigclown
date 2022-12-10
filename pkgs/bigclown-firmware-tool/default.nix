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
  version = "1.5.2";
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

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-firmware-tool";
    rev = "5aad583a57e7cff6877b9707065c006b76a73190";
    sha256 = "i28VewTB2XEZSfk0UeCuwB7Z2wz4qPBhzvxJIYkKwJ4=";
  };
}
