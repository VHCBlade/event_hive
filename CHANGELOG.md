## 0.2.0

* BREAKING CHANGE: Upgraded event_db to 0.2.0

## 0.1.6

* Added concrete implementation of saveModels in BaseHiveRepository 

## 0.1.5+1

* Added overrideType property that defaults to false. Set to true if it's possible that the initialize function will be called multiple times.

## 0.1.4

* Added BaseHiveRepository and base_event_hive.dart for use in non-Flutter environments.

## 0.1.3

* Upgraded minimum necessary event_db package to 0.1.3
* Changed default created id to use a uuid instead.

## 0.1.2

* Changed TypeMapper to be required, since it doesn't work if it's not provided.

## 0.1.1

* Fixed bug where initialization wait wasn't working correctly.

## 0.1.0

* Initial Release
