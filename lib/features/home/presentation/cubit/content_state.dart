import 'package:equatable/equatable.dart';

import '../../domain/entities/clickable_model/clickable_model.dart';

sealed class ContentState extends Equatable {
  const ContentState();
  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  final List<ClickableModel> models;
  final String baseUrl;

  const ContentLoaded({
    required this.models,
    required this.baseUrl,
  });

  @override
  List<Object> get props => [models];
}

class ContentError extends ContentState {
  final String message;

  const ContentError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
