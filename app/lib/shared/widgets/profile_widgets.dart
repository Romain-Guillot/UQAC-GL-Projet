import 'package:app/shared/models/user.dart';
import 'package:app/shared/res/assets.dart';
import 'package:app/shared/res/dimens.dart';
import 'package:app/shared/widgets/page_header.dart';
import 'package:app/user/profile_visualisation_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import 'package:app/main.dart';



/// Widget to display information about an user (name, age, etc)
///
/// It takes the [user] as parameter and can be clickable if the flag 
/// [isClickable] is set to true. If so, the page [UserProfileVisualisationPage]
/// will be opened to display all the user information.
/// 
/// The layout is a [ListTile] with the following information :
///   - the user profile picture
///   - the user name
///   - the user age
///   - the user spoken languages
class UserCard extends StatelessWidget {

  final User user;
  final bool isClickable;

  UserCard({@required this.user, this.isClickable = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: LayoutBuilder(
        builder: (_, constraints) =>
         SizedBox(
           width: constraints.maxHeight,
           height: constraints.maxHeight,
           child: ProfilePicture(url: user?.urlPhoto, rounded: true,)
         )
      ),
      title: Text(user?.name??"" + (user?.age != null ? ", ${user.age}" : "")),
      subtitle: user?.spokenLanguages == null || user.spokenLanguages.isEmpty
                  ? null
                  : Text(user.spokenLanguages),
      onTap: !isClickable ? null : () => openUserProfile(context),
    );
  }

  openUserProfile(context) {
    Navigator.of(context).push(MaterialPageRoute(builder: 
      (_) => UserProfileVisualisationPage(user: user)
    ));
  }
}


/// Display the user profile picture from the [url] of the default profile picture
///
/// If the url is non-null the image is displayed thanks to the [Image.network]
/// widget, else the [DefaultProfilePicture] is displayed.
/// 
/// The entire content is wrapped inside a [LayoutBuilder] to get the width
/// available to display a square image.
class ProfilePicture extends StatelessWidget {

  final String url;
  final bool rounded;
  
  ProfilePicture({@required this.url, this.rounded = false});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) { 
        var size = constraints.maxWidth;
        return ClipRRect(
          borderRadius: rounded ? Dimens.rounedBorderRadius : BorderRadius.zero,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: url == null
              ? DefaultProfilePicture()
              : CachedNetworkImage(
                  imageUrl: url,
                  errorWidget: (_, __, ___) => DefaultProfilePicture(),
                  placeholder: (_, __) => DefaultProfilePicture(),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                )
          ),
        );
      }
    );
  }
}



/// Display the default profile picture (used if the user hasn't a PP)
class DefaultProfilePicture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) { 
        final size = constraints.maxWidth;
        return Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: SvgPicture.asset(
              Assets.defaultProfilePicture, 
              height: size / 2,
              color: Theme.of(context).colorScheme.onSurfaceLight,
            ),
          )
        );
      }
    );
  }
}



/// Display a list of [UserCard]
///
/// An optionnal [title] can be provided, it will display the title in a 
/// [PageHeader]
/// 
/// An optionnal widget ([empty]) can be provided, it will be displayed if
/// the [users] list to display is empty
/// 
/// The [actionBarBuilder] can be used to build an action bar widget to display
/// below the user card.
class UserList extends StatelessWidget {

  final Widget title;
  final Widget empty;
  final List<User> users;
  final Widget Function(User) actionBarBuilder;

  UserList({
    Key key, 
    this.title,
    @required this.users,
    this.empty,
    this.actionBarBuilder
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (empty == null && (users == null || users.isEmpty))
      return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.screenPaddingValue),
            child: PageHeader(
              title: title,
            ),
          ),
        if (users == null || users.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.screenPaddingValue),
            child: empty
          ),
        if (users != null && users.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            itemCount: users?.length??0,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: Dimens.normalSpacing),
            separatorBuilder: (_, __) => SizedBox(height: Dimens.normalSpacing,),
            itemBuilder: (_, index) => Column(
              children: <Widget>[
                UserCard(
                  user: users[index], 
                  isClickable: true,
                ),
                if (actionBarBuilder != null)
                  actionBarBuilder(users[index]),
              ],
            )
          ),
      ],
    );
  }
}