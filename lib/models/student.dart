class Student {
  String name, rollNo, password, department;
  int currentSemester;

  List<String>? currentCourses;
  List<String>? joinedSocieties;

  Student(this.name, this.rollNo, this.password, this.currentSemester, this.department) {
    this.currentCourses = [];
    this.joinedSocieties = [];
  }
}
