class UserProfile {
  String username;
  String category;
  String sub;
  String profileImageUrl;
  int count;

  UserProfile(
      this.username, this.category, this.sub, this.profileImageUrl, this.count);

  factory UserProfile.fromMap(Map<String, dynamic> data, int count) {
    return UserProfile(
      data['username'] as String,
      data['category'] as String,
      data['sub'] as String,
      data['profileImageUrl'] as String ?? '',
      count,
    );
  }
}