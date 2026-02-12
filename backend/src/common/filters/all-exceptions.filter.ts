import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { CustomError } from '../error/custom-error';

type FieldError = { field: string; reason: string };

@Catch() // 모든 예외를 잡음
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();

    const timestamp = new Date().toISOString();

    // 1) CustomError
    if (exception instanceof CustomError) {
      return res.status(exception.statusCode).json({
        success: false,
        data: null,
        message: exception.message,
        code: exception.code,
        errors: exception.details ?? null,
        timestamp,
        path: req.url,
      });
    }

    // 2) Nest HttpException (ValidationPipe 에러 포함)
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const responseBody = exception.getResponse() as any;

      // ValidationPipe 에러 파싱 (Nest 기본 형태)
      const { message, code, errors } =
        this.normalizeHttpException(responseBody);

      return res.status(status).json({
        success: false,
        data: null,
        message,
        code,
        errors,
        timestamp,
        path: req.url,
      });
    }

    // 3) 그 외(알 수 없는 에러) => 500
    const msg =
      exception instanceof Error ? exception.message : 'Internal Server Error';

    return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      success: false,
      data: null,
      message: msg,
      code: 'INTERNAL_SERVER_ERROR',
      errors: null,
      timestamp,
      path: req.url,
    });
  }

  private normalizeHttpException(responseBody: any): {
    message: string;
    code: string;
    errors: FieldError[] | null;
  } {
    const rawMessage = responseBody?.message;

    if (Array.isArray(rawMessage)) {
      return {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        errors: rawMessage.map((m: string) => ({
          field: this.guessField(m),
          reason: m,
        })),
      };
    }

    // 일반 HttpException
    return {
      message: typeof rawMessage === 'string' ? rawMessage : 'Request failed',
      code: responseBody?.code ?? 'HTTP_ERROR',
      errors: null,
    };
  }

  private guessField(msg: string): string {
    const first = msg.split(' ')[0];
    return first?.replace(/[^a-zA-Z0-9_]/g, '') || 'unknown';
  }
}
