import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

double responsive(context,mobile,tab){
  return  MediaQuery.of(context).size.height < 430 || MediaQuery.of(context).size.width< 490 ? mobile : tab;
}
void navigateTo(context, widget) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => widget,
  ),
);
void navigatePushReplacement(context, widget) => Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => widget),
);

SnackBar? showToastSuccess(msg,context)
{
  final snackBar = SnackBar(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
    ),
    padding:const EdgeInsets.only(
      bottom:40,top: 10),
    dismissDirection: DismissDirection.up,
    duration: const Duration(seconds: 3),
    content: Center(
      child: Text(
        msg,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: responsive(context, 16.0, 24.0)),
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  return null;
}

SnackBar? showToastFailed(msg,context) {
  final snackBar = SnackBar(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
    ),
    padding:const EdgeInsets.only(
        bottom:40,top: 10),
    dismissDirection: DismissDirection.up,
    duration: const Duration(seconds: 3),
    content: Center(
      child: Text(
        msg,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: responsive(context, 16.0, 24.0)),
      ),
    ),
    backgroundColor: Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  return null;
}
Widget defaultFormField(
    {required TextEditingController controller,
      TextInputType? type,
      VoidCallback? onPressed,
      String? Function(String?)? onChange,
      String? Function(String?)? onSubmit,

      VoidCallback? onTab,
      String? Function(String?)? validator,
      required String label,
      bool isPassword = false,
      bool isClickable = true,
      required IconData prefixIcon,
      IconData? suffixIcon,
      VoidCallback? suffixPressed}) {
  return TextFormField(
    onTap: onTab,
    controller: controller,
    validator: validator,
    onFieldSubmitted: onSubmit,

    onChanged: onChange,
    enabled: isClickable,
    keyboardType: type,
    obscureText: isPassword == true ? true : false,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon != null
          ? IconButton(
        icon: Icon(suffixIcon),
        onPressed: suffixPressed,
      )
          : null,
      border: const OutlineInputBorder(),
    ),
  );
}

Future awesomeDialogSuccess(context,title) {
  return  AwesomeDialog(
    customHeader: Icon(Icons.check,size:100,color: Theme.of(context).primaryColor,),
    btnOkColor: Theme.of(context).primaryColor,
    btnOkText: okText,
    context: context,
    animType: AnimType.leftSlide,
    headerAnimationLoop: false,
    dialogType: DialogType.success,
    showCloseIcon: true,
    title: saveImageDone,
    btnOkOnPress: () {},
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) {},
  ).show();
}

Future awesomeDialogFailed(context,title) {
  return  AwesomeDialog(
    customHeader: Icon(Icons.close,size:100,color: Theme.of(context).primaryColor,),
    btnOkColor: Theme.of(context).primaryColor,
    btnOkText: okText,
    context: context,
    animType: AnimType.leftSlide,
    headerAnimationLoop: false,
    dialogType: DialogType.error,
    showCloseIcon: true,
    title: title,
    btnOkOnPress: () {},
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) {},
  ).show();
}

