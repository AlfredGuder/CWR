import 'package:documentation_assistant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

bool populateDummyData = true;

//create credentials
const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "cwr-gsheet",
  "private_key_id": "6f2612c22291182a8287873c9a87c13e8138135b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCVBGaTYFm5mgeU\n70FKE67cs1zvLK00Ls33z7Lr2uv/qqEl1lgh6bYofpDQnuSuCaTGuj+3EI10DWfS\nK7QSVsOg+QFlOYnX5R5WlB382AL5reHjWXMgC50BZvDaU+gHMQVzyKBkFZiBYHEg\nQpG2o3uiMqw7aRmm6XLNw0Jz+JnGrDnEF88tsnJdb08FYWegWx0p2UuCveMiqDeQ\neuryeZ4aPncH8ozk3DV32shsPF5NA2c2UFboA+IjNbu5FkR8SwEYtVL+ue2tQQT6\ndp8GIMdiDphvvIT3LVg3rv7H3n5Q0wRPLFzUK4Rz5SiWmkYaoCEwkfyGKOTnsRB6\nVHQcy8RvAgMBAAECggEANzEPEMyhzsVGw5mts9MAc8uWwxrn96jSLlNl8EcAG4xF\n7S6rK7xU9ECUQEBpcDAwME5xJMtjqLUCW+xF4Hj0Md2n76bU7/pzNxva03fp+jG1\ntS+/HQJQH2HSGPr0uB0m6NBI32jEOD7RB2LAd0Wrl9Juyf5OOuzB0YXdSfisc9Fq\n8lILMQaUV3Q74oqZhQYSxDnXX6cGBA9XVFmt+y+4BFlV218GR8QdslL+ZbOa3Del\nLjD+Mrs5QdotuW7PuSwQjm0sZsr77sudIHO9OH95NX5+EA2UPyFJLyaEkHwdIR5E\nzly9H/eiJhFaBr46bytdEMnnPQKfCH4WUjqxu1LosQKBgQDR0ipS/gQeH0K/k0B/\n0VNtbcJOt4XIv6xGuB/cPnP0OQbyjbQgwBPnge9223BmpqPCLMT+oapEkLxHX17v\ngoN3dgk+pZWhX+bXfpPdC6gMbvBwfEy58nIz6nHWBP2cfZw0XJE2lGmyaLFwATXo\nMk1Rvly/IPOXfGY6xWoD7aqUtwKBgQC10GZa/AlE9dlqybFSH5cKFcspM2Uu43iG\nW78RenjSIsLI0r4P76Tc3R3cgB9VRlnkfOmuUVMhIYEQKTIYBskndisAEThEDpVF\nik31M4LpMoGwnq05cgq8Auiu5OUa2T4chUXysywTxiBd6aA3q+oED97ySxB+dcZD\nx30EQnHGCQKBgDZu2YASWiseXQiqQO9n9MbM1L3rKo/7+cuW9N0EbryLFtxSGsrs\nSb2jneYt46kdzhoP10Nf2XZUPiQd/9kO+OBDBP71oi3tXUvGkMGlxoEDPulPte//\nj9UcG1A0lz7D74Q+B4YrVohsVKwEBGIquphcVF9ZQxinszXIBUrjm39dAoGARaTe\nkFua8V97OPypf9u575MJj26wg5V+xXi/Z+KSBWxrUKHpTBFwBWpt1dj+J5wbMvrm\nSG++eCJtXdNp7Oosg4EwV4ZBF1C+vTSNSC/DJbDDHPSrRiX5FqvGlbf4SqCMukAS\n2zTm3Ww3WcH0LV8c9RFfRVCbsNVMbQotSURqcIECgYAq/4Q6pV2G05y4l5pUqBzn\nSiB/8A3/SKhI94YgbRJzFFHRhzi5FS+b8iNY7KJvjBVHomF06IOFWLgt1W0neGM4\nCUq/qqMaWytr6Y2sWNNuAkOdPFyPY3CXRsZJGC/Rp+MpLBynzG8fSOjUkqidPWt8\nsXzjhzyANDreL3fh+mkbGg==\n-----END PRIVATE KEY-----\n",
  "client_email": "cwr-gsheet@cwr-gsheet.iam.gserviceaccount.com",
  "client_id": "103571088181722491554",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/cwr-gsheet%40cwr-gsheet.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

''';

//spreadsheet id
const _spreadsheetId = '1KC65Z6baN0ayLJmWN1npzzDXt6Lrdvsi0M4Z4FPdP3Y';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("animalFeedBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Documentation Assistant",
      home: MyHomePage(sheetCredentials: _credentials, sheetId: _spreadsheetId),
    );
  }
}
