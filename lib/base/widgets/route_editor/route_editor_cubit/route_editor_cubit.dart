import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'route_editor_state.dart';

class RouteEditorCubit extends Cubit<RouteEditorState> {
  RouteEditorCubit() : super(RouteEditorState());
}
