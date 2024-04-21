class UserProfile {
  String userId;
  String username;
  String category;
  String sub;
  String profileImageUrl;
  int count;

  UserProfile(
      this.userId, this.username, this.category, this.sub, this.profileImageUrl, this.count);

  factory UserProfile.fromMap(Map<String, dynamic> data, String userId, int count) {
    return UserProfile(
      userId,
      data['username'] as String,
      data['category'] as String,
      data['sub'] as String,
      data['profileImageUrl'] as String ?? '',
      count,
    );
  }
}