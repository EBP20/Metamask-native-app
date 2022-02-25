import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {required this.title, required this.color, required this.onTapped});

  final String title;
  final Color color;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0,
      child: InkWell(
        onTap: onTapped,
        child: Container(
          height: 40,
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(
                Radius.circular(18.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15.0,
                letterSpacing: 0.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
