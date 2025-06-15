import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/blocs/language/language_bloc.dart';
import 'package:frontend/presentation/blocs/language/language_event.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final Color primaryColor = const Color(0xFF326B80);
        final Color darkColor = Color(0xFFE0E0E0);
        final Color whiteColor = Colors.white70;
        final loc = AppLocalizations.of(context)!;

        // قائمة البطاقات للشريط
        final List<Map<String, dynamic>> carouselItems = [
          {
            'isLogo': true,
            'text': loc.welcomeLogo,
            'image': 'assets/welcome.png',
          },
          {
            'isLogo': false,
            'icon': Icons.search,
            'text': loc.exploreFields,
          },
          {
            'isLogo': false,
            'icon': Icons.question_answer,
            'text': loc.askQuestions,
          },
          {
            'isLogo': false,
            'icon': Icons.work,
            'text': loc.findJobs,
          },
          {
            'isLogo': false,
            'icon': Icons.person_add,
            'text': loc.addProfile,
          },
        ];

        return Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: Stack(
              children: [
                // المحتوى الرئيسي
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // شريط التمرير
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: true,
                              aspectRatio: 2.0,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlayInterval: const Duration(seconds: 5),
                            ),
                            items: carouselItems.map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: whiteColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (item['isLogo'] == true) ...[
                                          Image.asset(
                                            item['image'],
                                            height: 110,
                                            fit: BoxFit.contain,
                                          ),
                                        ] else ...[
                                          Icon(
                                            item['icon'],
                                            size: 80,
                                            color: whiteColor,
                                          ),
                                        ],
                                        const SizedBox(height: 20),
                                        Text(
                                          item['text'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // اسم التطبيق
                        Text(
                          loc.appName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // وصف مختصر
                        Text(
                          loc.welcomeDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: whiteColor),
                        ),
                        const SizedBox(height: 60),

                        // زرين Login و Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // زر Login
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: whiteColor),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                loc.login,
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // زر Sign Up
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                loc.signup,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // أيقونة اللغة في الأعلى اليمين
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: BlocBuilder<LanguageBloc, dynamic>(
                    builder: (context, state) {
                      return PopupMenuButton<String>(
                        icon: const Icon(Icons.language, color: Colors.white),
                        onSelected: (String value) {
                          context.read<LanguageBloc>().add(ChangeLanguageEvent(Locale(value)));
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'en',
                            child: Text('English'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'ar',
                            child: Text('العربية'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}