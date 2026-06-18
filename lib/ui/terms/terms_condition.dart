import 'package:airotrackgit/assets/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';

import '../../assets/resources/strings.dart';

class TermsCondition extends StatelessWidget {
  const TermsCondition({super.key});
  final terms = '''
<h1>Terms and Conditions</h1>
<p>By accessing or using the mobile application provided by <a href="https://airotrack.in/">airotrack.in</a> ("us", "we", or "our"), you agree to abide by the following terms and conditions:</p>
<ol>
  <li><strong>Acceptance of Terms</strong><br>
    By accessing or using our Service, you agree to be bound by these Terms and Conditions, as well as our Privacy Policy. If you do not agree to all the terms and conditions of this agreement, then you may not access the Service.</li>
  <li><strong>Personal Data</strong><br>
    We collect and use various types of information, including Personal Data, as described in our Privacy Policy. By using our Service, you consent to the collection and use of this information in accordance with our Privacy Policy.</li>
  <li><strong>Usage of Data</strong><br>
    You agree that we may use the collected data for various purposes, including but not limited to providing and maintaining the Service, notifying you about changes to our Service, providing customer support, and improving the Service.</li>
  <li><strong>Cookies and Tracking Technologies</strong><br>
    We use cookies and similar tracking technologies to enhance your experience on our Service and to collect information. By using our Service, you consent to the use of cookies and tracking technologies as described in our Privacy Policy.</li>
  <li><strong>Security</strong><br>
    While we strive to protect your Personal Data, you acknowledge that no method of transmission over the Internet or electronic storage is 100% secure. You agree to use our Service at your own risk.</li>
  <li><strong>Third-Party Service Providers</strong><br>
    We may employ third-party companies and individuals to facilitate our Service, and they may have access to your Personal Data only to perform tasks on our behalf. You agree to the use of such third-party service providers.</li>
  <li><strong>Links to Third-Party Sites</strong><br>
    Our Service may contain links to third-party websites or services that are not operated by us. We have no control over, and assume no responsibility for, the content, privacy policies, or practices of any third-party sites or services. You agree to review the privacy policies of any third-party sites you visit.</li>
  <li><strong>Children's Privacy</strong><br>
    Our Service is not intended for children under the age of 18 ("Children"). We do not knowingly collect personally identifiable information from anyone under the age of 18. If you are a parent or guardian and you believe your child has provided us with Personal Data, please contact us immediately.</li>
  <li><strong>Changes to Terms and Conditions</strong><br>
    We reserve the right to update or modify these Terms and Conditions at any time without prior notice. Any changes will be effective immediately upon posting the updated Terms and Conditions on our website. You are encouraged to review these Terms and Conditions periodically for any changes.<br>
    By continuing to access or use our Service after any revisions become effective, you agree to be bound by the revised terms. If you do not agree to the new terms, you are no longer authorized to use the Service.</li>
  <li><strong>Governing Law</strong><br>
    These Terms and Conditions shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.</li>
</ol>
''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorPrimary,
          title: const Text(
            Strings.terms,
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
            child: Html(data: terms),
          )),
        ));
  }
}
