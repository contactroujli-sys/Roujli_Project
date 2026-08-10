import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_data_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();

  @override
  Future<ProfileData> getProfileData() async {
    final model = await _dataSource.getProfileData();
    return _mapToEntity(model);
  }

  @override
  Future<void> updateProfileData(Map<String, dynamic> data) async {
    await _dataSource.updateProfileData(data);
  }

  @override
  Future<void> updateBusinessData(Map<String, dynamic> data) async {
    await _dataSource.updateBusinessData(data);
  }

  @override
  Future<void> deleteBusiness() async {
    await _dataSource.deleteBusiness();
  }

  ProfileData _mapToEntity(ProfileDataModel model) {
    return ProfileData(
      user: UserProfile(
        firstName: model.user.firstName,
        lastName: model.user.lastName,
        email: model.user.email,
        phoneNumber: model.user.phoneNumber,
        avatar: model.user.avatar,
        bio: model.user.bio,
        country: model.user.country,
        city: model.user.city,
        isVerified: model.user.isVerified,
        growthScore: model.user.growthScore,
        business: model.user.business != null
            ? BusinessInfo(
                id: model.user.business!.id,
                name: model.user.business!.name,
                slug: model.user.business!.slug,
                description: model.user.business!.description,
                logo: model.user.business!.logo,
                cover: model.user.business!.cover,
                phone: model.user.business!.phone,
                email: model.user.business!.email,
                website: model.user.business!.website,
                whatsapp: model.user.business!.whatsapp,
                address: model.user.business!.address,
                verified: model.user.business!.verified,
                growthScore: model.user.business!.growthScore,
                monthlyGrowth: model.user.business!.monthlyGrowth,
              )
            : null,
      ),
      businessCounts: model.businessCounts.map((count) => BusinessCount(
        type: count.type,
        count: count.count,
      )).toList(),
      membership: Membership(
        type: model.membership.type,
        status: model.membership.status,
        expiresAt: model.membership.expiresAt != null 
            ? DateTime.parse(model.membership.expiresAt!) 
            : null,
      ),
    );
  }
}
