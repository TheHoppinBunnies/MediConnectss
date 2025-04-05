import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Data Models
struct MedicalImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let category: MedicalImageCategory
    let dateAdded: Date
    var notes: String
}

enum MedicalImageCategory: String, CaseIterable, Identifiable {
    case xray = "X-ray"
    case prescription = "Prescription"
    case labResult = "Lab Result"
    case scan = "Scan/MRI"
    case medication = "Medication"
    case other = "Other"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .xray: return "xray"
        case .prescription: return "doc.text"
        case .labResult: return "list.clipboard"
        case .scan: return "brain.head.profile"
        case .medication: return "pill"
        case .other: return "photo"
        }
    }
}

// MARK: - Make UIImage Transferable
extension UIImage: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .png) { image in
            if let data = image.pngData() {
                return data
            }
            return Data()
        } importing: { data in
            guard let image = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return image
        }
    }

    enum TransferError: Error {
        case importFailed
    }
}

// MARK: - View Models
class MedicalImageLibrary: ObservableObject {
    @Published var images: [MedicalImage] = []

    func addImage(_ image: UIImage, category: MedicalImageCategory, notes: String = "") {
        let newImage = MedicalImage(image: image, category: category, dateAdded: Date(), notes: notes)
        images.append(newImage)
    }

    func deleteImage(at indexSet: IndexSet) {
        images.remove(atOffsets: indexSet)
    }
}

// MARK: - Views
struct MedicalPictureManagerView: View {
    @StateObject private var imageLibrary = MedicalImageLibrary()
    @State private var isShowingImagePicker = false
    @State private var isShowingCategorySheet = false
    @State private var selectedImage: UIImage?
    @State private var selectedCategory: MedicalImageCategory = .other
    @State private var imageNotes: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                if imageLibrary.images.isEmpty {
                    emptyStateView
                } else {
                    imageListView
                }
            }
            .navigationTitle("Medical Images")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isShowingImagePicker = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            isShowingCategorySheet = true
                        }
                    }
            }
            .sheet(isPresented: $isShowingCategorySheet) {
                categorySelectionView
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 70))
                .foregroundColor(.gray)

            Text("No Medical Images")
                .font(.title2)
                .fontWeight(.medium)

            Text("Tap the + button to add X-rays, prescriptions, and other medical images.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { isShowingImagePicker = true }) {
                Text("Add First Image")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var imageListView: some View {
        List {
            ForEach(MedicalImageCategory.allCases) { category in
                if !imageLibrary.images.filter({ $0.category == category }).isEmpty {
                    Section(header: Text(category.rawValue)) {
                        ForEach(imageLibrary.images.filter { $0.category == category }) { item in
                            NavigationLink(destination: MedicalImageDetailView(image: item)) {
                                MedicalImageRow(image: item)
                            }
                        }
                        .onDelete { indexSet in
                            let filteredImages = imageLibrary.images.filter { $0.category == category }
                            indexSet.forEach { index in
                                if let globalIndex = imageLibrary.images.firstIndex(where: { $0.id == filteredImages[index].id }) {
                                    imageLibrary.images.remove(at: globalIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var categorySelectionView: some View {
        NavigationStack {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding()
                }

                Form {
                    Section(header: Text("Select Category")) {
                        ForEach(MedicalImageCategory.allCases) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .frame(width: 30)

                                    Text(category.rawValue)

                                    Spacer()

                                    if selectedCategory == category {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }

                    Section(header: Text("Notes (Optional)")) {
                        TextEditor(text: $imageNotes)
                            .frame(minHeight: 100)
                    }

                    Section {
                        Button(action: saveImage) {
                            Text("Save Image")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Add Medical Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selectedImage = nil
                        isShowingCategorySheet = false
                    }
                }
            }
        }
    }

    private func saveImage() {
        if let image = selectedImage {
            imageLibrary.addImage(image, category: selectedCategory, notes: imageNotes)
            selectedImage = nil
            imageNotes = ""
            isShowingCategorySheet = false
        }
    }
}

struct MedicalImageRow: View {
    let image: MedicalImage

    var body: some View {
        HStack {
            Image(uiImage: image.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(image.category.rawValue)
                    .font(.headline)

                if !image.notes.isEmpty {
                    Text(image.notes.prefix(50) + (image.notes.count > 50 ? "..." : ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(image.dateAdded.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MedicalImageDetailView: View {
    let image: MedicalImage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: image.category.icon)
                        Text(image.category.rawValue)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                    Text("Added on \(image.dateAdded.formatted(date: .long, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !image.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        Text(image.notes)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Image Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: image.image, preview: SharePreview("Medical Image", image: Image(uiImage: image.image)))
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct MedicalPictureManagerView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalPictureManagerView()
    }
}
