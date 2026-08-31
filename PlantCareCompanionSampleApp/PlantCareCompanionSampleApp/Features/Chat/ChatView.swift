/*
 Copyright (c) 2020-present, salesforce.com, inc. All rights reserved.

 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import SwiftUI

/// Chat view that displays AgentforceChatView when SDK is integrated
struct ChatView: View {
    @State private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Get theme colors for the current scheme
    private var colors: PlantCareTheme.Colors {
        PlantCareTheme.Colors(colorScheme: colorScheme)
    }
    
    init(viewModel: ChatViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let chatView = viewModel.chatView {
                    chatView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    loadingView
                }
            }
            .navigationTitle("Plant Care Expert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(colors.textSecondary)
                    }
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: PlantCareTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Connecting to Plant Expert...")
                .font(PlantCareTheme.Typography.body)
                .foregroundColor(colors.textSecondary)
        }
    }
    
    private func errorView(_ error: PlantCareError) -> some View {
        VStack(spacing: PlantCareTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(colors.error)
            
            Text("Unable to Connect")
                .font(PlantCareTheme.Typography.title)
                .foregroundColor(colors.textPrimary)
            
            Text(error.localizedDescription)
                .font(PlantCareTheme.Typography.body)
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Dismiss") {
                dismiss()
            }
            .plantCarePrimaryButton(colors: colors)
        }
        .padding()
    }
}

#Preview {
    let compositionRoot = CompositionRoot()
    return ChatView(viewModel: compositionRoot.makeChatViewModel())
}
