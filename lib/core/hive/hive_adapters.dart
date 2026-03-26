// lib/hive/hive_adapters.dart   ← keep registrar but REMOVE the spec
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';


@GenerateAdapters(<AdapterSpec<dynamic>>[
  AdapterSpec<ThemeUiModel>(), 
]) // or just omit the list entirely
part 'hive_adapters.g.dart';
