// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoding extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ClickableModel> movies;
  final List<ClickableModel> series;
  final List<ClickableModel> kdramas;
  final List<ClickableModel> anime;
  final List<ClickableModel> hindi;
  final List<ClickableModel> animation;
  final List<ClickableModel> south;
  final List<ClickableModel> bangla;
  final List<ClickableModel> foreign;

  const HomeLoaded({
    required this.movies,
    required this.hindi,
    required this.animation,
    required this.south,
    required this.bangla,
    required this.series,
    required this.kdramas,
    required this.anime,
    required this.foreign,
  });

  @override
  List<Object> get props => [movies, series, kdramas, anime];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
