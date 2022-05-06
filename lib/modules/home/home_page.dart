import 'package:flutter/material.dart';

import '../extract/extract_page.dart';
import 'home_controller.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_text_styles.dart';
import '../meus_boletos/meus_boletos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();
  final pages = [const MeusBoletosPage(), const ExtratPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(152),
        child: Container(
          height: 152,
          color: AppColors.primary,
          child: Center(
            child: ListTile(
              title: Text.rich(
                TextSpan(
                  text: 'Olá, ',
                  style: TextStyles.titleRegular,
                  children: [
                    TextSpan(
                        text: 'Roberto, ',
                        style: TextStyles.titleBoldBackground),
                  ],
                ),
              ),
              subtitle: Text('Mantenha suas contas em dia',
                  style: TextStyles.captionShape),
              trailing: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      ),
      body: pages[controller.currentPage],
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                controller.setPage(0);

                setState(() {});
              },
              icon: const Icon(Icons.home),
              color: controller.currentPage == 0
                  ? AppColors.primary
                  : AppColors.body,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, '/barcode_scanner');
                Navigator.pushNamed(context, '/insert_boleto');
              },
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(
                  Icons.add_box_outlined,
                  color: AppColors.background,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                controller.setPage(1);
                setState(() {});
              },
              icon: const Icon(Icons.description_outlined),
              color: controller.currentPage == 1
                  ? AppColors.primary
                  : AppColors.body,
            )
          ],
        ),
      ),
    );
  }
}
