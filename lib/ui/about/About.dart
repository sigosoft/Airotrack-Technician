import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';

import '../../assets/resources/colors.dart';
import '../../assets/resources/strings.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  final aboutUs = '''
<h1>About Us</h1>
<p>We are the manufacturer of the premium quality vehicle location tracking system (VLTS) IRNSS & GPS. Speed Tech Solution is the old name of Airo Track Technologies PVT LTD. We assure timely delivery of these Speed Governors to the clientele from our end. We have well-experienced and trained engineers to process Manufacture of IRNSS Device And GPS Vehicle Track Device. Our Installation Services are cost-effective and technically sound so that the customer can have very good performance of the installed vehicle tracking device.</p>
<ul>
  <li>IRNSS Vehicle Track</li>
  <li>GPS Vehicle Track</li>
  <li>AIS-140</li>
</ul>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          title: const Text(
            Strings.aboutUs,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins-Bold',
                fontWeight: FontWeight.bold),
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset('lib/assets/images/back.svg',
                height: 20, width: 20, fit: BoxFit.scaleDown),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Html(data: aboutUs)),
          ),
        ));
  }
}
