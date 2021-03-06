// RUN: %empty-directory(%t)
// RUN: cp %s %t/input.swift
// RUN: %target-swift-frontend -c -update-code -primary-file %t/input.swift -emit-migrated-file-path %t/always_remove_old_remap_file.result -emit-remap-file-path %t/always_remove_old_remap_file.remap %api_diff_data_dir -o /dev/null %api_diff_data_dir
// RUN: ls %t/always_remove_old_remap_file.remap

// Simulate leaving behind code that can't build in Swift 4:
// RUN: echo asdfads >> %t/input.swift

// Migrate again. This should delete the old remap file.
// RUN: not %target-swift-frontend -c -update-code -primary-file %t/input.swift -emit-migrated-file-path %t/always_remove_old_remap_file.result -emit-remap-file-path %t/always_remove_old_remap_file.remap %api_diff_data_dir -o /dev/null %api_diff_data_dir

// RUN: not ls %t/always_remove_old_remap_file.remap

func foo() {}
