# Changelog

## 4.3.0
### Features

- OpenTelemetry-Swift upgrade to 1.9.1

## 4.2.5
### Features

- Add PrivacyInfo Integration

### Fixes

- Fix mem leak while posting logs
- Fix crash if no network connection while posting logs

## 4.2.4

### Features

- Add xcframework build scripts support

## 4.2.3

### Fixes

- fix `EXC_BAD_ACCESS` crash while post logs

## 4.2.2

### Features

- Upgrade alinetworkdiagnosis to 0.2.2.1

## 4.2.1

### Features

- Upgrade OpenTelemetryApi & SDK to 1.6.0
- Add URLSessionInstrumentation support
- Add CocoasPod support

## 4.2.0

### Features

- Add addLog to CrashReporter
- Add reportException to CrashReporter
- Add more callback infomation while sending log

## 4.1.1

### Features

- Expose additional information in the producer callback

## 4.1.0

### Features

- Add link data between trace and network diagnosis

## 4.0.0

### Features

- Add Uem Crashreporter support
- Add OTelCommon module
- Add OtlpSLSSpanExporter
- Upgrade WPKMobi


### Fixes

- Fix rand() security problem

### Breaking changes

- CrashReporter will no longer be supported. Use CrashReporter2.
