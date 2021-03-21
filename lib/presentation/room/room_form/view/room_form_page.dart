/*
 * room_form_page.dart  
 *
 * Creator:
 * 3/20/21 11:38 AM sebastianguggisberg
 *
 * Maintainer:
 * 3/20/21 11:38 AM sebastianguggisberg
 *
 * Last Modification:
 * $Id: $
 *
 */

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:start_hack/domain/room/room.dart';
import 'package:start_hack/injection.dart';
import 'package:start_hack/presentation/core/savings_overlay.dart';
import 'package:start_hack/presentation/room/room_form/bloc/room_form_bloc.dart';
import 'package:start_hack/presentation/room/room_form/view/widgets/break_duration_field.dart';
import 'package:start_hack/presentation/room/room_form/view/widgets/room_date_field.dart';
import 'package:start_hack/presentation/room/room_form/view/widgets/room_description_field.dart';
import 'package:start_hack/presentation/room/room_form/view/widgets/room_name_field.dart';
import 'package:start_hack/presentation/room/room_form/view/widgets/room_type_field.dart';

class RoomFormPage extends StatelessWidget {
  final Room editedRoom;

  const RoomFormPage({
    Key key,
    @required this.editedRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => getIt<RoomFormBloc>()
          ..add(RoomFormEvent.initialized(
            optionOf(editedRoom),
          )),
        child: BlocBuilder<RoomFormBloc, RoomFormState>(
          buildWhen: (previousState, currentState) =>
              previousState.isSaving != currentState.isSaving,
          builder: (context, state) {
            return Stack(
              children: <Widget>[
                RoomFormPageScaffold(),
                SavingOverlay(isSaving: state.isSaving)
              ],
            );
          },
        ),
      ),
    );
  }
}

class RoomFormPageScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RoomFormBloc, RoomFormState>(
        listener: (context, state) {
          if (state.informationComplete) {
            state.valueFailureOrOk.fold(
              () {},
              (failure) {
                final snackBar = SnackBar(
                  content: Text(failure.maybeMap(
                    exceedingLength: (_) => 'Text ist too long!',
                    orElse: () => 'Unexpected error',
                  )),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            );

            state.saveFailureOrSuccessOption.fold(
              () => {},
              (either) {
                either.fold(
                  (failure) {
                    final snackBar = SnackBar(
                      content: Text(failure.maybeMap(
                        insufficientPermission: (_) =>
                            'Insufficient permissions',
                        unableToUpdate: (_) => "Couldn't update the ascent. ",
                        orElse: () =>
                            'Unexpected error occured, please contact support.',
                      )),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  (_) {
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Form(
            child: SingleChildScrollView(
              child: Align(
                alignment: const Alignment(0, -1 / 3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your fabulous new chill",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RoomTypeField(),
                      const SizedBox(height: 24),
                      RoomNameField(),
                      const SizedBox(height: 24),
                      RoomDateField(),
                      const SizedBox(height: 24),
                      BreakDurationField(),
                      const SizedBox(height: 24),
                      RoomDescriptionField(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Invite-only?"),
                          const SizedBox(width: 150),
                          CupertinoSwitch(
                            activeColor: Color(0xff9841e4),
                              trackColor: Colors.grey,
                              value: state.room.inviteOnly,
                              onChanged: (value) => context
                                  .read<RoomFormBloc>()
                                  .add(RoomFormEvent.inviteOnlyChanged(value)))
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return Color(0xff7500C0);
                            },
                          ),
                        ),
                        onPressed: state.informationComplete
                            ? () {
                                context
                                    .read<RoomFormBloc>()
                                    .add(const RoomFormEvent.saved());
                              }
                            : null,
                        child: const Text(
                          "Create room",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
