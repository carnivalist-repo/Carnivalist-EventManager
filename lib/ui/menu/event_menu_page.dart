import 'package:eventmanagement/bloc/event/basic/basic_bloc.dart';
import 'package:eventmanagement/bloc/event/basic/basic_state.dart';
import 'package:eventmanagement/bloc/event/form/form_bloc.dart';
import 'package:eventmanagement/bloc/event/gallery/gallery_bloc.dart';
import 'package:eventmanagement/bloc/event/setting/setting_bloc.dart';
import 'package:eventmanagement/bloc/event/tickets/tickets_bloc.dart';
import 'package:eventmanagement/intl/app_localizations.dart';
import 'package:eventmanagement/main.dart';
import 'package:eventmanagement/model/event/basic/basic_response.dart';
import 'package:eventmanagement/model/event/form/form_action_response.dart';
import 'package:eventmanagement/model/event/gallery/gallery_response.dart';
import 'package:eventmanagement/model/event/settings/setting_response.dart';
import 'package:eventmanagement/ui/page/event/basic/basic_page.dart';
import 'package:eventmanagement/ui/page/event/forms/forms_page.dart';
import 'package:eventmanagement/ui/page/event/gallery/gallery_page.dart';
import 'package:eventmanagement/ui/page/event/settings/setting_page.dart';
import 'package:eventmanagement/ui/page/event/ticket/tickets_page.dart';
import 'package:eventmanagement/utils/extensions.dart';
import 'package:eventmanagement/utils/vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventMenuPage extends StatefulWidget {
  EventMenuPage({Key key}) : super(key: key);

  @override
  createState() => _EventMenuState();
}

class _EventMenuState extends State<EventMenuPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextStyle tabStyle = TextStyle(fontSize: 16);

  BasicBloc _basicBloc;
  TicketsBloc _ticketsBloc;
  FormBloc _formBloc;
  GalleryBloc _galleryBloc;
  SettingBloc _settingBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      _basicBloc.selectedTabChange(_tabController.index);
    });

    _basicBloc = BlocProvider.of<BasicBloc>(context);
    _ticketsBloc = BlocProvider.of<TicketsBloc>(context);
    _formBloc = BlocProvider.of<FormBloc>(context);
    _galleryBloc = BlocProvider.of<GalleryBloc>(context);
    _settingBloc = BlocProvider.of<SettingBloc>(context);

    //TODO(Existing Event) Get existing event data via navigator and populate all the states here
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.0),
            padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
            child: Row(children: <Widget>[
              Expanded(
                child: RaisedButton(
                  onPressed: previous,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    AppLocalizations
                        .of(context)
                        .btnPrevious,
                    style: Theme
                        .of(context)
                        .textTheme
                        .button,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: RaisedButton(
                  onPressed: next,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    AppLocalizations
                        .of(context)
                        .btnSubmit,
                    style: Theme
                        .of(context)
                        .textTheme
                        .button,
                  ),
                ),
              )
            ])),
        body: Column(children: <Widget>[
          BlocBuilder<BasicBloc, BasicState>(
            bloc: _basicBloc,
            condition: (prevState, newState) => newState.errorCode != null,
            builder: (context, BasicState state) {
              if (state.errorCode != null) {
                String errorMsg = getErrorMessage(state.errorCode, context);
                if (state.errorCode == ERR_START_DATE_WEEK_DAY ||
                    state.errorCode == ERR_END_DATE_WEEK_DAY)
                  context.toast(
                      '$errorMsg${uiLabelWeekday(
                          state.eventWeekday, context)}');
                else
                  context.toast(errorMsg);

                state.errorCode = null;
              }

              return SizedBox.shrink();
            },
          ),
          Container(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: Icon(
                          isPlatformAndroid
                              ? Icons.arrow_back
                              : CupertinoIcons.back,
                          color: Theme
                              .of(context)
                              .appBarTheme
                              .iconTheme
                              .color,
                        ),
                        onPressed: Navigator
                            .of(context)
                            .pop),
                  ),
                  Center(
                    child: Text(
                      AppLocalizations
                          .of(context)
                          .titleCreateEvent,
                      style: Theme
                          .of(context)
                          .appBarTheme
                          .textTheme
                          .title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(headerBackgroundImage),
                    fit: BoxFit.fitWidth,
                  ))),
          const SizedBox(height: 16.0),
          Expanded(
              child: DefaultTabController(
                  length: 5,
                  child: Column(children: <Widget>[
                    BlocBuilder<BasicBloc, BasicState>(
                        bloc: _basicBloc,
                        condition: (prevState, newState) =>
                        prevState.selectedTab != newState.selectedTab,
                        builder: (context, BasicState state) {
                          return TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            indicatorColor: Colors.transparent,
                            labelPadding: EdgeInsets.all(4),
                            isScrollable: false,
                            indicatorSize: TabBarIndicatorSize.tab,
                            onTap: (pos) {
                              if (pos > 0 && !isValid(_basicBloc.eventDataId)) {
                                context.toast(
                                    AppLocalizations
                                        .of(context)
                                        .validateStep1);
                                _tabController.index = 0;
                              }
                            },
                            tabs: [
                              Tab(
                                child: tabName('1', state.selectedTab, 0,
                                    AppLocalizations
                                        .of(context)
                                        .menuBasic),
                              ),
                              Tab(
                                child: tabName('2', state.selectedTab, 1,
                                    AppLocalizations
                                        .of(context)
                                        .menuTickets),
                              ),
                              Tab(
                                child: tabName('3', state.selectedTab, 2,
                                    AppLocalizations
                                        .of(context)
                                        .menuForms),
                              ),
                              Tab(
                                child: tabName('4', state.selectedTab, 3,
                                    AppLocalizations
                                        .of(context)
                                        .menuGallery),
                              ),
                              Tab(
                                child: tabName('5', state.selectedTab, 4,
                                    AppLocalizations
                                        .of(context)
                                        .menuSettings),
                              )
                            ],
                          );
                        }),
                    Expanded(
                      child: TabBarView(
                        physics: isValid(_basicBloc.eventDataId)
                            ? null
                            : NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          BasicPage(),
                          TicketsPage(),
                          FormsPage(),
                          GalleryPage(),
                          SettingPage()
                        ],
                      ),
                    ),
                  ])))
        ]));
  }

  @override
  bool get wantKeepAlive => false;

  tabName(String index, int selectIndex, int defaultIndex, String name) =>
      Container(
          decoration: BoxDecoration(
              color: selectIndex == defaultIndex ? bgColorButton : Colors.white,
              borderRadius: BorderRadius.circular(5)),
          child: Align(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      index,
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .copyWith(
                        color: selectIndex == defaultIndex
                            ? Colors.white
                            : Theme
                            .of(context)
                            .textTheme
                            .subhead
                            .color,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      name,
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .copyWith(
                        color: selectIndex == defaultIndex
                            ? Colors.white
                            : Theme
                            .of(context)
                            .textTheme
                            .subhead
                            .color,
                      ),
                    )
                  ])));

  void next() {
    if (_tabController.index == 0) {
      context.showProgress(context);

      _basicBloc.basic((results) {
        context.hideProgress(context);

        if (results is BasicResponse) {
          var basicResponse = results;

          if (basicResponse.code == apiCodeSuccess) {
            context.toast(basicResponse.message);
            _tabController.animateTo(1);
          } else {
            context.toast(basicResponse.message);
          }
        } else if (results is String) {
          context.toast(results);
        }

        FocusScope.of(context).requestFocus(FocusNode());
      });
    } else if (_tabController.index == 1) {
      if (_ticketsBloc.state.ticketsList.length > 0) {
        _tabController.animateTo(2);
      } else {
        context.toast(AppLocalizations
            .of(context)
            .errorTicketLength);
      }
    } else if (_tabController.index == 2) {
      context.showProgress(context);

      _formBloc.uploadFields((results) {
        context.hideProgress(context);

        if (results is FormActionResponse) {
          var formActionResponse = results;

          if (formActionResponse.code == apiCodeSuccess) {
            context.toast(formActionResponse.message);
            _tabController.animateTo(3);
          } else {
            context.toast(formActionResponse.message);
          }
        } else if (results is String) {
          if (results == 'Upload not required')
            _tabController.animateTo(3);
          else
            context.toast(results);
        }
      });
    } else if (_tabController.index == 3) {
      context.showProgress(context);

      _galleryBloc.uploadGallery((results) {
        context.hideProgress(context);

        if (results is GalleryResponse) {
          var galleryResponse = results;
          if (galleryResponse.code == apiCodeSuccess) {
            context.toast(galleryResponse.message);
            _tabController.animateTo(4);
          } else {
            context.toast(galleryResponse.message);
          }
        } else if (results is String) {
          if (results == 'Upload not required')
            _tabController.animateTo(4);
          else
            context.toast(results);
        }
      });
    } else if (_tabController.index == 4) {
      if (_basicBloc.state.uploadRequired) {
        context.toast(AppLocalizations
            .of(context)
            .errorUnsavedBasic);
        return;
      }

      if (_ticketsBloc.state.ticketsList.length == 0) {
        context.toast(AppLocalizations
            .of(context)
            .errorTicketLength);
        return;
      }

      if (_formBloc.state.uploadRequired) {
        context.toast(AppLocalizations
            .of(context)
            .errorUnsavedForm);
        return;
      }

      if (_galleryBloc.state.uploadRequired) {
        context.toast(AppLocalizations
            .of(context)
            .errorUnsavedGallery);
        return;
      }

      context.showProgress(context);

      _settingBloc.uploadSettings((results) {
        context.hideProgress(context);

        if (results is SettingResponse) {
          var settingResponse = results;
          if (settingResponse.code == apiCodeSuccess) {
            context.toast(settingResponse.message);
            Navigator.of(context).pop();
          } else {
            context.toast(settingResponse.message);
          }
        } else if (results is String) {
          context.toast(results);
        }
      });
    }
  }

  void previous() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }
}
