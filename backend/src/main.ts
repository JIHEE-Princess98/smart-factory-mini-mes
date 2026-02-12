import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { ResponseIntercepter } from './common/intercepters/response.intercepter';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  //Success response
  app.useGlobalInterceptors(new ResponseIntercepter()); //응답값 전역적으로 적용

  //Error Response
  app.useGlobalFilters(new AllExceptionsFilter());

  app.setGlobalPrefix('api');
  await app.listen(8080);
}
bootstrap();
