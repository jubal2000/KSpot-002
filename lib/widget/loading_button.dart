import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    Key? key,
    this.primary,
    this.isLoading = false,
    required this.child,
    required this.onPressed,
  }) : super(key: key);
  final Widget child;
  final VoidCallback onPressed;
  final Color? primary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : child,
      style: ElevatedButton.styleFrom(primary: primary),
    );
  }
}
