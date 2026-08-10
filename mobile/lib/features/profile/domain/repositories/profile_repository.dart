import '../entities/profile_data.dart';

abstract class ProfileRepository {
  Future<ProfileData> getProfileData();
  Future<void> updateProfileData(Map<String, dynamic> data);
  Future<void> updateBusinessData(Map<String, dynamic> data);
  Future<void> deleteBusiness();
}
