import 'dart:convert';
import 'dart:io';

import 'package:app_course/features/updates/update_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient _github(String tag, {int status = 200}) => MockClient((request) async {
  expect(request.url.toString(), latestReleaseApi);
  return http.Response(
    jsonEncode({
      'tag_name': tag,
      'html_url': 'https://github.com/Drekstord/elan/releases/tag/$tag',
      'assets': [
        {
          'name': 'ELAN-$tag.apk',
          'browser_download_url': 'https://github.com/Drekstord/elan/releases/download/ELAN-$tag.apk',
        },
        {
          'name': 'ELAN-Installation-$tag.exe',
          'browser_download_url': 'https://github.com/Drekstord/elan/releases/download/ELAN-Installation-$tag.exe',
        },
        {
          'name': 'ELAN-serveur-$tag.zip',
          'browser_download_url': 'https://github.com/Drekstord/elan/releases/download/serveur.zip',
        },
      ],
    }),
    status,
  );
});

void main() {
  test('comparaison des numéros de version', () {
    expect(compareVersions('v2.9.0', '2.8.2'), greaterThan(0));
    expect(compareVersions('2.8.10', '2.8.9'), greaterThan(0));
    expect(compareVersions('v2.8.2', '2.8.2+15'), 0);
    expect(compareVersions('2.8', '2.8.1'), lessThan(0));
  });

  test('version plus récente : fichier de cet appareil', () async {
    final apk = await fetchUpdate(current: '2.8.2', assetSuffix: '.apk', client: _github('v2.9.0'));
    expect(apk!.version, '2.9.0');
    expect(apk.downloadUrl, 'https://github.com/Drekstord/elan/releases/download/ELAN-v2.9.0.apk');
    final exe = await fetchUpdate(current: '2.8.2', assetSuffix: '.exe', client: _github('v2.9.0'));
    expect(exe!.downloadUrl, 'https://github.com/Drekstord/elan/releases/download/ELAN-Installation-v2.9.0.exe');
    final other = await fetchUpdate(current: '2.8.2', client: _github('v2.9.0'));
    expect(other!.downloadUrl, other.pageUrl);
  });

  test('à jour, erreur ou pas de réseau : rien à proposer', () async {
    expect(await fetchUpdate(current: '2.9.0', client: _github('v2.9.0')), isNull);
    expect(await fetchUpdate(current: '2.9.1', client: _github('v2.9.0')), isNull);
    expect(await fetchUpdate(current: '2.8.0', client: _github('v2.9.0', status: 403)), isNull);
    final offline = MockClient((_) => throw const SocketException('pas de réseau'));
    expect(await fetchUpdate(current: '2.8.0', client: offline), isNull);
  });
}
