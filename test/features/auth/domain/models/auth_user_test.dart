import 'package:attendance_app/features/auth/domain/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser Role-Based Access Control (RBAC)', () {
    test('admin role has isAdmin=true, isStaff=true, isInstructor=false, isStudent=false', () {
      const admin = AuthUser(
        id: 'admin_1',
        email: 'admin@system.local',
        name: 'Super Admin',
        role: 'admin',
      );

      expect(admin.isAdmin, isTrue);
      expect(admin.isStaff, isTrue);
      expect(admin.isInstructor, isFalse);
      expect(admin.isStudent, isFalse);
    });

    test('instructor role has isInstructor=true, isStaff=true, isAdmin=false, isStudent=false', () {
      const instructor = AuthUser(
        id: 'inst_1',
        email: 'instructor@elevate.edu',
        name: 'Certified Instructor',
        role: 'instructor',
      );

      expect(instructor.isAdmin, isFalse);
      expect(instructor.isStaff, isTrue);
      expect(instructor.isInstructor, isTrue);
      expect(instructor.isStudent, isFalse);
    });

    test('student role has isStudent=true, isStaff=false, isAdmin=false, isInstructor=false', () {
      const student = AuthUser(
        id: 'std_1',
        email: 'student@elevate.edu',
        name: 'Enrolled Student',
        role: 'student',
      );

      expect(student.isAdmin, isFalse);
      expect(student.isStaff, isFalse);
      expect(student.isInstructor, isFalse);
      expect(student.isStudent, isTrue);
    });

    test('default role is student when unspecified', () {
      const user = AuthUser(
        id: 'usr_default',
        email: 'default@elevate.edu',
        name: 'Default User',
      );

      expect(user.role, 'student');
      expect(user.isAdmin, isFalse);
      expect(user.isStaff, isFalse);
      expect(user.isStudent, isTrue);
    });
  });
}
