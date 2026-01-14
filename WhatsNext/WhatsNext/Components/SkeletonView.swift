//
//  SkeletonView.swift
//  WhatsNext
//
//  Loading states and skeleton screens for better UX
//

import SwiftUI

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 500
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Skeleton Shape

struct SkeletonShape: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = DesignTokens.CornerRadius.sm) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DesignTokens.Colors.neutral200)
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Skeleton Text

struct SkeletonText: View {
    let lines: Int
    let lineSpacing: CGFloat

    init(lines: Int = 1, lineSpacing: CGFloat = DesignTokens.Spacing.xs) {
        self.lines = lines
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(0..<lines, id: \.self) { index in
                SkeletonShape(
                    width: randomWidth(for: index),
                    height: 16,
                    cornerRadius: DesignTokens.CornerRadius.xs
                )
            }
        }
    }

    private func randomWidth(for index: Int) -> CGFloat? {
        // Last line is usually shorter
        if index == lines - 1 && lines > 1 {
            return CGFloat.random(in: 100...200)
        }
        return nil // Full width
    }
}

// MARK: - Skeleton Goal Row

struct SkeletonGoalRow: View {
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Checkbox placeholder
            Circle()
                .fill(DesignTokens.Colors.neutral200)
                .frame(width: 24, height: 24)
                .shimmer()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                // Title
                SkeletonShape(width: 200, height: 16)

                // Badges
                HStack(spacing: DesignTokens.Spacing.sm) {
                    SkeletonShape(width: 60, height: 20, cornerRadius: DesignTokens.CornerRadius.round)
                    SkeletonShape(width: 80, height: 20, cornerRadius: DesignTokens.CornerRadius.round)
                    SkeletonShape(width: 50, height: 20, cornerRadius: DesignTokens.CornerRadius.round)
                }
            }

            Spacer()
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .padding(.horizontal, DesignTokens.Spacing.xs)
    }
}

// MARK: - Skeleton Card

struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Header
            HStack {
                Circle()
                    .fill(DesignTokens.Colors.neutral200)
                    .frame(width: 8, height: 8)
                    .shimmer()

                Spacer()

                SkeletonShape(width: 60, height: 20, cornerRadius: DesignTokens.CornerRadius.sm)
            }

            // Title
            SkeletonText(lines: 2)

            // Description
            SkeletonText(lines: 1)

            // Metadata
            HStack(spacing: DesignTokens.Spacing.xs) {
                SkeletonShape(width: 50, height: 18, cornerRadius: DesignTokens.CornerRadius.round)
                SkeletonShape(width: 40, height: 18, cornerRadius: DesignTokens.CornerRadius.round)
            }

            // Tags
            HStack(spacing: DesignTokens.Spacing.xs) {
                SkeletonShape(width: 60, height: 18, cornerRadius: DesignTokens.CornerRadius.round)
                SkeletonShape(width: 50, height: 18, cornerRadius: DesignTokens.CornerRadius.round)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle(elevation: .small)
    }
}

// MARK: - Loading State

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var error: Error? {
        if case .failed(let error) = self { return error }
        return nil
    }
}

// MARK: - Loading View

struct LoadingView: View {
    let message: String

    init(message: String = "Loading...") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(DesignTokens.Colors.accent)

            Text(message)
                .font(DesignTokens.Typography.bodyMedium)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.surfacePrimary)
    }
}

// MARK: - Skeleton List

struct SkeletonList: View {
    let rows: Int

    init(rows: Int = 5) {
        self.rows = rows
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(0..<rows, id: \.self) { _ in
                SkeletonGoalRow()
            }
        }
        .padding(DesignTokens.Spacing.lg)
    }
}

// MARK: - Skeleton Grid

struct SkeletonGrid: View {
    let columns: Int
    let rows: Int

    init(columns: Int = 4, rows: Int = 3) {
        self.columns = columns
        self.rows = rows
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                ForEach(0..<columns, id: \.self) { _ in
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(0..<rows, id: \.self) { _ in
                            SkeletonCard()
                                .frame(width: 280)
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Async Content View

struct AsyncContentView<Content: View, Value>: View {
    let state: LoadingState<Value>
    let onRetry: (() -> Void)?
    @ViewBuilder let content: (Value) -> Content

    init(
        state: LoadingState<Value>,
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.onRetry = onRetry
        self.content = content
    }

    var body: some View {
        switch state {
        case .idle:
            EmptyView()

        case .loading:
            LoadingView()

        case .loaded(let value):
            content(value)

        case .failed(let error):
            VStack(spacing: DesignTokens.Spacing.lg) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: DesignTokens.IconSize.xxl))
                    .foregroundStyle(DesignTokens.Colors.error)

                Text("Something went wrong")
                    .font(DesignTokens.Typography.h3)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)

                Text(error.localizedDescription)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                if let onRetry = onRetry {
                    Button("Try Again", action: onRetry)
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.Colors.accent)
                }
            }
            .padding(DesignTokens.Spacing.xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.Colors.surfacePrimary)
        }
    }
}

// MARK: - Previews

#Preview("Skeleton Goal Row") {
    VStack {
        SkeletonGoalRow()
        SkeletonGoalRow()
        SkeletonGoalRow()
    }
    .padding()
}

#Preview("Skeleton Card") {
    SkeletonCard()
        .frame(width: 280)
        .padding()
}

#Preview("Skeleton List") {
    SkeletonList(rows: 5)
}

#Preview("Skeleton Grid") {
    SkeletonGrid(columns: 4, rows: 3)
        .frame(height: 600)
}

#Preview("Loading View") {
    LoadingView(message: "Loading your goals...")
}

#Preview("Error State") {
    AsyncContentView(
        state: LoadingState<String>.failed(NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load data"])),
        onRetry: {}
    ) { value in
        Text(value)
    }
}
