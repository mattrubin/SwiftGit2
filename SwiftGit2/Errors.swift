import Foundation
import libgit2

public let libGit2ErrorDomain = "org.libgit2.libgit2"

public struct GitError: CustomNSError {
	public let code: git_error_code
	public let message: String?
	public let type: git_error_t?
	public let pointOfFailure: String?

	/// Returns a GitError representing the libgit2 error with the given error code.
	///
	/// - parameter code: An error code returned by a libgit2 function.
	/// - parameter pointOfFailure: The name of the libgit2 function that produced the error code.
	/// - returns: A GitError with a libgit2 error code and message.
	internal init(code: git_error_code, pointOfFailure: String? = nil) {
		self.code = code
		self.pointOfFailure = pointOfFailure

		if let lastErrorPointer = giterr_last() {
			message = String(validatingUTF8: lastErrorPointer.pointee.message)
			type = git_error_t(UInt32(lastErrorPointer.pointee.klass))
		} else {
			message = nil
			type = nil
		}
	}

	public var userInfo: [String : String] {
		var userInfo: [String: String] = [:]

		if let message = message {
			userInfo[NSLocalizedDescriptionKey] = message
		} else {
			userInfo[NSLocalizedDescriptionKey] = "Unknown libgit2 error."
		}

		if let pointOfFailure = pointOfFailure {
			userInfo[NSLocalizedFailureReasonErrorKey] = "\(pointOfFailure) failed."
		}

		return userInfo
	}
}
