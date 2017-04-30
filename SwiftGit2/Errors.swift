import Foundation
import libgit2

public let libGit2ErrorDomain = "org.libgit2.libgit2"

public struct GitError: CustomNSError {
	public let domain: String
	public let code: git_error_code
	public let message: String?

	public let userInfo: [String : String]
}

internal extension GitError {
	/// Returns an NSError with an error domain and message for libgit2 errors.
	///
	/// :param: errorCode An error code returned by a libgit2 function.
	/// :param: libGit2PointOfFailure The name of the libgit2 function that produced the
	///         error code.
	/// :returns: An NSError with a libgit2 error domain, code, and message.
	internal init(code: git_error_code, pointOfFailure: String? = nil) {
		let message: String?
		if let lastErrorPointer = giterr_last(),
			let errorMessage = String(validatingUTF8: lastErrorPointer.pointee.message) {
			message = errorMessage
		} else {
			message = nil
		}

		var userInfo: [String: String] = [:]

		if let message = message {
			userInfo[NSLocalizedDescriptionKey] = message
		} else {
			userInfo[NSLocalizedDescriptionKey] = "Unknown libgit2 error."
		}

		if let pointOfFailure = pointOfFailure {
			userInfo[NSLocalizedFailureReasonErrorKey] = "\(pointOfFailure) failed."
		}

		self.init(domain: libGit2ErrorDomain, code: code, message: message, userInfo: userInfo)
	}
}
