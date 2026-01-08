# SwiftData Relationship Fix

## The Problem

The `loadIssueModelContainer` error indicates a relationship configuration issue. The many-to-many relationship between `Goal` and `Tag` was causing the schema validation to fail.

## The Fix

I've moved the `@Relationship` annotation to the `Tag` side:

**Before:**
- Goal: `@Relationship(deleteRule: .nullify, inverse: \Tag.goals)`
- Tag: `var goals: [Goal]?` (no annotation)

**After:**
- Goal: `var tags: [Tag]?` (no annotation, inverse side)
- Tag: `@Relationship(deleteRule: .nullify, inverse: \Goal.tags)`

## Why This Should Work

In SwiftData, for many-to-many relationships:
- Only ONE side should have the `@Relationship` annotation
- The side with `@Relationship` specifies the `inverse` parameter
- The other side is just a regular property (the inverse)

By moving the annotation to `Tag`, we're defining the relationship from Tag's perspective, with Goal.tags as the inverse.

## Next Steps

1. **Clean Build Folder**: ⌘ + Shift + K
2. **Rebuild**: ⌘ + B
3. **Run**: ⌘ + R
4. **Check Console**: Look for "✅ ModelContainer created successfully"

This should resolve the `loadIssueModelContainer` error!
