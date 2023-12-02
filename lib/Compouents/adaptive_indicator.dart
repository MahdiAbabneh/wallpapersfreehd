import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdaptiveIndicator extends StatelessWidget {

  const AdaptiveIndicator({super.key,
  });

  @override
  Widget build(BuildContext context) {
      return  Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Theme.of(context).primaryColor,
          size: MediaQuery.of(context).size.width * 0.4,
        ),
      );
  }
}
