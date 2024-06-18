import 'package:flutter/material.dart';

class ActionSheet extends StatelessWidget {
  const ActionSheet({
    super.key,
    required this.confirm,
    required this.title,
    required this.text,
  });

  final VoidCallback confirm;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            width: double.infinity,
            alignment: Alignment.center,
            height: 66,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff212226),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Container(
            color: Color(0xff212226).withOpacity(0.1),
            height: 1,
          ),
          InkWell(
            onTap: confirm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              alignment: Alignment.center,
              height: 66,
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xffEC2F2F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xff949BA5).withOpacity(0.1),
            height: 8,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Color(0xffF9F9F9),
                  ),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xff212226),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
