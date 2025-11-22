import { Injectable } from '@nestjs/common';
import { v2 as cloudinary, UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';
import { Readable } from 'stream';

@Injectable()
export class CloudinaryService {
  async uploadImage(
    file: Express.Multer.File,
    folder: string = 'recycling-materials',
  ): Promise<UploadApiResponse> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: folder,
          resource_type: 'auto',
          transformation: [
            { width: 1200, height: 1200, crop: 'limit' },
            { quality: 'auto:good' },
          ],
        },
        (error: UploadApiErrorResponse | undefined, result: UploadApiResponse | undefined) => {
          if (error) return reject(error);
          if (result) return resolve(result);
          reject(new Error('Upload failed'));
        },
      );

      // Convert buffer to stream and pipe to Cloudinary
      const bufferStream = new Readable();
      bufferStream.push(file.buffer);
      bufferStream.push(null);
      bufferStream.pipe(uploadStream);
    });
  }

  async deleteImage(publicId: string): Promise<any> {
    return cloudinary.uploader.destroy(publicId);
  }

  // Extract public_id from Cloudinary URL
  extractPublicId(url: string): string {
    const parts = url.split('/');
    const filename = parts[parts.length - 1];
    const publicId = filename.split('.')[0];
    // Include folder path if exists
    const folderIndex = parts.indexOf('upload') + 1;
    if (folderIndex > 0 && folderIndex < parts.length - 1) {
      const folders = parts.slice(folderIndex + 1, -1);
      return [...folders, publicId].join('/');
    }
    return publicId;
  }
}

