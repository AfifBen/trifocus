import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/local_storage.dart';
import '../../domain/models/project.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/path.dart';

class LibraryState {
  final List<Project> projects;
  final List<Habit> habits;
  final List<Path> paths;

  const LibraryState({
    required this.projects,
    required this.habits,
    required this.paths,
  });

  LibraryState copyWith({
    List<Project>? projects,
    List<Habit>? habits,
    List<Path>? paths,
  }) {
    return LibraryState(
      projects: projects ?? this.projects,
      habits: habits ?? this.habits,
      paths: paths ?? this.paths,
    );
  }
}

final libraryProvider = StateNotifierProvider<LibraryController, LibraryState>(
  (ref) => LibraryController()..load(),
);

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController()
      : super(const LibraryState(projects: [], habits: [], paths: []));

  Future<void> load() async {
    final projects = await LocalStorage.loadProjects();
    final habits = await LocalStorage.loadHabits();
    final paths = await LocalStorage.loadPaths();
    state = state.copyWith(projects: projects, habits: habits, paths: paths);
  }

  Future<void> addProject(Project item) async {
    final items = [...state.projects, item];
    state = state.copyWith(projects: items);
    await LocalStorage.saveProjects(items);
  }

  Future<void> removeProject(String id) async {
    final items = state.projects.where((e) => e.id != id).toList();
    state = state.copyWith(projects: items);
    await LocalStorage.saveProjects(items);
  }

  Future<void> addHabit(Habit item) async {
    final items = [...state.habits, item];
    state = state.copyWith(habits: items);
    await LocalStorage.saveHabits(items);
  }

  Future<void> removeHabit(String id) async {
    final items = state.habits.where((e) => e.id != id).toList();
    state = state.copyWith(habits: items);
    await LocalStorage.saveHabits(items);
  }

  Future<void> addPath(Path item) async {
    final items = [...state.paths, item];
    state = state.copyWith(paths: items);
    await LocalStorage.savePaths(items);
  }

  Future<void> removePath(String id) async {
    final items = state.paths.where((e) => e.id != id).toList();
    state = state.copyWith(paths: items);
    await LocalStorage.savePaths(items);
  }
}
