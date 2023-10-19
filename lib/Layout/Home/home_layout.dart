import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallpaper_app/models/CustomBannerAd.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min,
            children: [
              BottomNavigationBar(
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.white,
                items: cubit.item,
                currentIndex:cubit.indexScreen ,
                onTap: (index){
                  cubit.selectItem(index);
                },
              ),
              // SizedBox(height: 10,),
              // const CustomBannerAd(),
              // SizedBox(height: 20,)
            ],
          ),
          body:cubit.screen[cubit.indexScreen],
        );
      });
  }

}
