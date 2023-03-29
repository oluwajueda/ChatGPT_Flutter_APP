import 'package:ask_anything/constant/constants.dart';
import 'package:ask_anything/services/api_services.dart';
import 'package:ask_anything/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ModelsDropDown extends StatefulWidget {
  const ModelsDropDown({super.key});

  @override
  State<ModelsDropDown> createState() => _ModelsDropDownState();
}

class _ModelsDropDownState extends State<ModelsDropDown> {
  String currentModel = "text-davinci-003";
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ApiService.getModels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: TextWidget(label: snapshot.error.toString()),
            );
          }
          return snapshot.data == null || snapshot.data!.isEmpty
              ? const SizedBox.shrink()
              : FittedBox(
                  child: DropdownButton(
                      dropdownColor: scaffoldBackgroundColor,
                      iconEnabledColor: Colors.white,
                      items: List<DropdownMenuItem<String>>.generate(
                        snapshot.data!.length,
                        (index) => DropdownMenuItem(
                          value: snapshot.data![index].id,
                          child: TextWidget(
                            label: snapshot.data![index].id,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      value: currentModel,
                      onChanged: (value) {
                        setState(() {
                          currentModel = value.toString();
                        });
                      }),
                );
        });
  }
}


// DropdownButton(
//         dropdownColor: scaffoldBackgroundColor,
//         iconEnabledColor: Colors.white,
//         items: getModelsItem,
//         value: currentModel,
//         onChanged: (value) {
//           setState(() {
//             currentModel = value.toString();
//           });
//         });