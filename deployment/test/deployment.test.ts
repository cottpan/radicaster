import { App } from 'aws-cdk-lib';
import { Template } from 'aws-cdk-lib/assertions';
import { RadicasterStack } from '../lib/radicaster-stack';

test('RadicasterStack creates expected resources', () => {
  // Set required environment variables for test
  process.env.RADICASTER_S3_BUCKET = 'test-bucket';
  process.env.RADICASTER_BASIC_AUTH_USER = 'testuser';
  process.env.RADICASTER_BASIC_AUTH_PASSWORD = 'testpass';
  
  const app = new App();
  // WHEN - EdgeFunction requires explicit region
  const stack = new RadicasterStack(app, 'MyTestStack', {
    env: {
      account: '123456789012',
      region: 'us-east-1'
    }
  });
  // THEN
  const template = Template.fromStack(stack);
  // Check that S3 bucket is created
  template.resourceCountIs('AWS::S3::Bucket', 1);
  // Check that Lambda functions are created
  template.resourceCountIs('AWS::Lambda::Function', 4); // rec-radiko, gen-feed, basic-auth edge function, and edge function version
  // Check that CloudFront distribution is created
  template.resourceCountIs('AWS::CloudFront::Distribution', 1);
});
